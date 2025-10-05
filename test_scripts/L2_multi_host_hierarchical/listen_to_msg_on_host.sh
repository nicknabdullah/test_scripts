#!/bin/bash
# listen_l2_msg_on_host.sh
#
# Usage:
#   ./listen_l2_msg_on_host <host_namespace> <host_ifname>
#
# Example:
#   ./listen_l2_msg_on_host.sh host10 eth10

if [ $# -ne 2 ]; then
  echo "Usage: $0 <host_namespace> <veth>"
  exit 1
fi

NAMESPACE=$1
IFNAME=$2

echo "Listening on $NAMESPACE veth ($IFNAME)..."
sudo ip netns exec "$NAMESPACE" tcpdump -i "$IFNAME" ether proto 0x7a05 -vv -l -A

