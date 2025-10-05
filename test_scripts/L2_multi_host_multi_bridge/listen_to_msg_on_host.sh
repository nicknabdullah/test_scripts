#!/bin/bash
# listen_l2_msg_on_host.sh
#
# Usage:
#   ./listen_l2_msg_on_host <host_namespace> <veth>
#
# Example:
#   ./listen_l2_msg_on_host.sh pc2 vt-pc2

if [ $# -ne 2 ]; then
  echo "Usage: $0 <host_namespace> <veth>"
  exit 1
fi

NS=$1
VETH=$2

echo "Listening on $NS veth ($VETH)..."
sudo ip netns exec "$NS" tcpdump -i "$VETH" ether proto 0x7a05 -vv -l -A

