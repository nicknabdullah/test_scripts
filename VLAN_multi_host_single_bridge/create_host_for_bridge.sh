#!/bin/bash
#
# Usage:
#   ./create_host_for_bridge.sh <host-ns> <peer1-if> <vlan-id> <bridge-ns> <bridge-if>
#
# Example:
#   ./create_host_for_bridge.sh host1 veth1 10 ns1 br0
#
# This script creates an end host namespace, connects it to a bridge
# using a veth pair, and assigns it to a VLAN.

create_end_host() {
  local host_nsname="$1"     # Name of the end host namespace
  local peer1_ifname="$2"    # veth interface inside the host namespace
  local peer2_ifname="${2}b" # veth interface inside the bridge namespace
  local vlan_vid="$3"        # VLAN ID to assign
  local bridge_nsname="$4"   # Bridge namespace name
  local bridge_ifname="$5"   # Bridge interface name

  # Check arguments
  if [[ -z "$host_nsname" || -z "$peer1_ifname" || -z "$vlan_vid" || -z "$bridge_nsname" || -z "$bridge_ifname" ]]; then
    echo "Error: missing arguments."
    echo "Usage: $0 <host-ns> <peer1-if> <vlan-id> <bridge-ns> <bridge-if>"
    exit 1
  fi

  echo "Creating end host '${host_nsname}' connected to bridge '${bridge_nsname}/${bridge_ifname}' (VLAN ${vlan_vid})..."

  # Create end host network namespace
  ip netns add "${host_nsname}"

  # Bring up loopback in the host namespace
  ip netns exec "${host_nsname}" ip link set lo up

  # Create a veth pair connecting host namespace to bridge namespace
  ip link add "${peer1_ifname}" netns "${host_nsname}" type veth peer \
              "${peer2_ifname}" netns "${bridge_nsname}"

  # Bring up the veth interface inside the host namespace
  ip netns exec "${host_nsname}" ip link set "${peer1_ifname}" up

  # Bring up the peer interface inside the bridge namespace
  ip netns exec "${bridge_nsname}" ip link set "${peer2_ifname}" up

  # Attach the peer interface to the bridge
  ip netns exec "${bridge_nsname}" ip link set "${peer2_ifname}" master "${bridge_ifname}"

  # Remove default VLAN (VID 1) from the peer interface
  ip netns exec "${bridge_nsname}" bridge vlan del dev "${peer2_ifname}" vid 1

  # Add the interface to the specified VLAN, mark it as PVID (untagged ingress)
  ip netns exec "${bridge_nsname}" bridge vlan add dev "${peer2_ifname}" vid "${vlan_vid}" pvid "${vlan_vid}"
}

# Call the function with the first five command-line arguments (safe version)
create_end_host "$1" "$2" "$3" "$4" "$5"

