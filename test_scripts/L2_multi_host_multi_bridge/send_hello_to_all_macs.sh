#!/bin/bash
# send_hello_to_all.sh
#
# Usage:
#   ./send_hello_to_all.sh <src_host> <src_host_veth>
#
# Example:
#   ./send_hello_to_all.sh pc1 vt-pc1

if [ $# -ne 2 ]; then
  echo "Usage: $0 <src_host> <src_host_veth>"
  exit 1
fi

SRC_NS=$1
SRC_VETH=$2

BROADCAST_MAC="ff:ff:ff:ff:ff:ff"
MESSAGE="Hello !"

echo "Source: $SRC_NS/$SRC_VETH"
echo "Sending broadcast message: \"$MESSAGE\""

# Send Ethernet frame with broadcast destination
sudo ip netns exec "$SRC_NS" ./ethsend.py "$SRC_VETH" "$BROADCAST_MAC" "$MESSAGE"

