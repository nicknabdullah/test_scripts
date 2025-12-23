#!/bin/bash
# send_hello_to_all.sh
#
# Usage:
#   ./send_hello_to_all.sh <src_host> <src_host_ifname>
#
# Example:
#   ./send_hello_to_all.sh host10 eth10

if [ $# -ne 2 ]; then
  echo "Usage: $0 <src_host> <src_host_ifname>"
  exit 1
fi

SRC_HOST=$1
SRC_IFNAME=$2

BROADCAST_MAC="ff:ff:ff:ff:ff:ff"
MESSAGE="Hello !"

echo "Source: $SRC_HOST/$SRC_IFNAME"
echo "Sending broadcast message: \"$MESSAGE\""

# Send Ethernet frame with broadcast destination
sudo ip netns exec "$SRC_HOST" ./ethsend.py "$SRC_IFNAME" "$BROADCAST_MAC" "$MESSAGE"

