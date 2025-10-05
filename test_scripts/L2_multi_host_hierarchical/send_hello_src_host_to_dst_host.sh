#!/bin/bash
# send_hello_src_host_to_dst_host.sh
#
# Usage:
#   ./send_hello_src_host_to_dst_host.sh <src_HOST> <src_ifname> <dst_HOST> <dst_ifname>
#
# Example:
#   ./send_hello_src_host_to_dst_host.sh host10 eth10 host20 eth20

if [ $# -ne 4 ]; then
  echo "Usage: $0 <src_host> <src_ifname> <dst_host> <dst_ifname>"
  exit 1
fi

SRC_HOST=$1
SRC_IFNAME=$2
DST_HOST=$3
DST_IFNAME=$4

# Auto-generate message
MESSAGE="Hello $DST_HOST!"

# Get destination IFNAME MAC inside destination namespace
DST_MAC=$(ip netns exec "$DST_HOST" ip link show "$DST_IFNAME" | awk '/ether/ {print $2}')
if [ -z "$DST_MAC" ]; then
  echo "Error: Could not retrieve MAC address for $DST_IFNAME in namespace $DST_HOST"
  exit 1
fi

echo "Destination MAC ($DST_HOST/$DST_IFNAME): $DST_MAC"
echo "Message: $MESSAGE"

# Send frame from source namespace/interface to destination MAC
sudo ip netns exec "$SRC_HOST" ./ethsend.py "$SRC_IFNAME" "$DST_MAC" "$MESSAGE"

