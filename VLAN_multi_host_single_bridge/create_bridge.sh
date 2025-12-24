#!/bin/bash
#
# Usage:
#   ./create_bridge.sh <namespace> <bridge-name>
#
# Example:
#   ./create_bridge.sh bridge0 br0
#
# This script creates a network namespace and a bridge inside it,
# then enables VLAN filtering on that bridge.


create_bridge() {
  local nsname="$1"
  local ifname="$2"

  # Check arguments
  if [[ -z "$nsname" || -z "$ifname" ]]; then
    echo "Error: missing arguments."
    echo "Usage: $0 <namespace> <bridge-name>"
    exit 1
  fi

  echo "Creating bridge '${ifname}' inside namespace '${nsname}'..."

  # Create a new network namespace
  ip netns add "${nsname}"

  # Bring up the loopback interface inside the namespace (needed for networking)
  ip netns exec "${nsname}" ip link set lo up

  # Create a new bridge device inside the namespace
  ip netns exec "${nsname}" ip link add "${ifname}" type bridge

  # Bring the bridge interface up so it can forward traffic
  ip netns exec "${nsname}" ip link set "${ifname}" up

  # Enable VLAN filtering on the bridge (important for isolating VLAN traffic)
  ip netns exec "${nsname}" ip link set "${ifname}" type bridge vlan_filtering 1
}

# Call the function with the first two command-line arguments (safe version)
create_bridge "$1" "$2"

