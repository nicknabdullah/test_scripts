#!/bin/bash

# ===============================
# Script: create_bridge.sh
# Usage: ./create_bridge.sh <namespace> <bridge_name>
# Example: ./create_bridge.sh bridge0 br0
#
# This script creates a network namespace and a bridge interface inside it.
# ===============================

# Check if both arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <namespace> <bridge_name>"
  echo "Example: $0 bridge0 br0"
  exit 1
fi

create_bridge() {
  local nsname="$1"
  local ifname="$2"

  echo "Creating bridge ${nsname}/${ifname}"

  # Create a new network namespace
  ip netns add "${nsname}"

  # Enable the loopback interface inside the namespace (needed for local communication)
  ip netns exec "${nsname}" ip link set lo up

  # Create a bridge interface inside the namespace
  ip netns exec "${nsname}" ip link add "${ifname}" type bridge

  # Bring the bridge interface up
  ip netns exec "${nsname}" ip link set "${ifname}" up
}

# Call the function with provided arguments
create_bridge "$1" "$2"

