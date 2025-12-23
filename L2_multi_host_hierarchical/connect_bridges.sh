#!/bin/bash
# connect_bridges.sh <bridge1_namespace> <bridge1_ifname> <bridge2_namespace> <bridge2_ifname>

if [ $# -ne 4 ]; then
  echo "Usage: $0 <bridge1_namespace> <bridge1_ifname> <bridge2_namespace> <bridge2_ifname>"
  exit 1
fi

bridge1_nsname="$1"
bridge1_ifname="$2"
bridge2_nsname="$3"
bridge2_ifname="$4"

veth1_ifname="veth_${bridge1_ifname}_${bridge2_ifname}"
veth2_ifname="veth_${bridge2_ifname}_${bridge1_ifname}"

echo "Connecting ${bridge1_nsname}/${bridge1_ifname} ↔ ${bridge2_nsname}/${bridge2_ifname}"

# Create veth pair
ip link add ${veth1_ifname} netns ${bridge1_nsname} type veth \
            peer ${veth2_ifname} netns ${bridge2_nsname}

# Bring them up
ip netns exec ${bridge1_nsname} ip link set ${veth1_ifname} up
ip netns exec ${bridge2_nsname} ip link set ${veth2_ifname} up

# Attach to bridges
ip netns exec ${bridge1_nsname} ip link set ${veth1_ifname} master ${bridge1_ifname}
ip netns exec ${bridge2_nsname} ip link set ${veth2_ifname} master ${bridge2_ifname}

