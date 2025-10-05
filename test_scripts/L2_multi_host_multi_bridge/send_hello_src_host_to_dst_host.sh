#!/bin/bash
# send_hello_src_host_to_dst_host.sh
#
# Usage:
#   ./send_hello_src_host_to_dst_host.sh <src_ns> <src_veth> <dst_ns> <dst_veth>
#
# Example:
#   ./send_hello_src_host_to_dst_host.sh pc1 vt-pc1 pc2 vt-pc2

if [ $# -ne 4 ]; then
  echo "Usage: $0 <src_host> <src_veth> <dst_host> <dst_veth>"
  exit 1
fi

SRC_NS=$1
SRC_VETH=$2
DST_NS=$3
DST_VETH=$4

# Auto-generate message
MESSAGE="Hello $DST_NS!"

# Get destination veth MAC inside destination namespace
DST_MAC=$(ip netns exec "$DST_NS" ip link show "$DST_VETH" | awk '/ether/ {print $2}')
if [ -z "$DST_MAC" ]; then
  echo "Error: Could not retrieve MAC address for $DST_VETH in namespace $DST_NS"
  exit 1
fi

echo "Destination MAC ($DST_NS/$DST_VETH): $DST_MAC"
echo "Message: $MESSAGE"

# Send frame from source namespace/interface to destination MAC
sudo ip netns exec "$SRC_NS" ./ethsend.py "$SRC_VETH" "$DST_MAC" "$MESSAGE"

