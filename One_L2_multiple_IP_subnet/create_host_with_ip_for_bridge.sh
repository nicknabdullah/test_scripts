#!/bin/bash

# ==========================================
# Script: create_host_with_ip_for_bridge.sh
# Usage: ./create_host_with_ip_for_bridge.sh <host_nsname> <host_ifname> <host_ifaddr> <bridge_nsname> <bridge_ifname>
# Example: ./create_host_with_ip_for_bridge.sh host10 eth10 10.0.0.1/24 bridge0 br0
#
# This script creates an end host namespace, assigns it an IP address,
# connects it to a bridge (in another namespace) via a veth pair,
# and attaches the peer side to the bridge.
# ==========================================

# Check if all required arguments are provided
if [ $# -ne 5 ]; then
  echo "Usage: $0 <host_nsname> <host_ifname> <host_ifaddr> <bridge_nsname> <bridge_ifname>"
  echo "Example: $0 host10 eth10 10.0.0.1/24 bridge0 br0"
  exit 1
fi

create_host_with_ip_for_bridge() {
  local host_nsname="$1"       # Namespace name for the end host
  local peer1_ifname="$2"      # Veth interface inside host namespace
  local peer2_ifname="${2}b"   # Veth interface inside bridge namespace (auto-suffixed with "b")
  local peer1_ifaddr="$3"      # IP address for host's interface
  local bridge_nsname="$4"     # Namespace where bridge lives
  local bridge_ifname="$5"     # Bridge interface name

  echo "Creating end host ${host_nsname} (${peer1_ifaddr}) connected to ${bridge_nsname}/${bridge_ifname}"

  # 1. Create the end host namespace and bring up loopback
  ip netns add "${host_nsname}"
  ip netns exec "${host_nsname}" ip link set lo up

  # 2. Create a veth pair in the default namespace
  ip link add "${peer1_ifname}" type veth peer name "${peer2_ifname}"

  # 3. Move each interface to its respective namespace
  ip link set "${peer1_ifname}" netns "${host_nsname}"
  ip link set "${peer2_ifname}" netns "${bridge_nsname}"

  # 4. Bring both interfaces up (host side and bridge side).
  ip netns exec "${host_nsname}" ip link set "${peer1_ifname}" up
  ip netns exec "${bridge_nsname}" ip link set "${peer2_ifname}" up

  # 5. Assign IP address to host's interface.
  ip netns exec "${host_nsname}" ip addr add "${peer1_ifaddr}" dev "${peer1_ifname}"

  # 6. Attach the bridge-side interface to the bridge.
  ip netns exec "${bridge_nsname}" ip link set "${peer2_ifname}" master "${bridge_ifname}"
}

# Call the function with provided arguments
create_host_with_ip_for_bridge "$1" "$2" "$3" "$4" "$5"

