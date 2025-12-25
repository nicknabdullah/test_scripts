#!/usr/bin/env bash
# send_msg_to_host_mac.sh
# Usage:
#   sudo ./send_msg_to_host_mac.sh <src_namespace> <interface> <destination_mac> "<message>"
# Example:
#   sudo ./send_msg_to_host_mac.sh host20 eth20 ff:ff:ff:ff:ff:ff "Hello VLAN 20!"

# Check for correct number of arguments
if [ "$#" -lt 4 ]; then
  echo "Usage: $0 <src_namespace> <interface> <destination_mac> \"<message>\""
  exit 1
fi

SRC_NS="$1"
IFACE="$2"
DSTMAC="$3"
MESSAGE="$4"

# Check if namespace exists
if ! ip netns list | grep -qw "$SRC_NS"; then
  echo "Error: Namespace '$SRC_NS' does not exist."
  exit 1
fi

# Check if interface exists inside the namespace
if ! sudo ip netns exec "$SRC_NS" ip link show "$IFACE" &>/dev/null; then
  echo "Error: Interface '$IFACE' not found in namespace '$SRC_NS'."
  exit 1
fi

# Run the Python script inside the specified namespace
sudo ip netns exec "$SRC_NS" python3 ethsend.py "$IFACE" "$DSTMAC" "$MESSAGE"

