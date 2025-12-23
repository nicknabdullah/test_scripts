#!/bin/bash
# send_L2_hello_from_host1_to_host3.sh

# Get host3 -> veth MAC (eg. vt-host3 is the veth of host3)
ETH3_MAC=$(ip netns exec host3 ip link show vt-host3 | awk '/ether/ {print $2}')
echo "Host3 veth MAC: $ETH3_MAC"

# Send frame from host1 veth (eg. vt-host1 is the veth of host1) to host3 veth
sudo ip netns exec host1 ./ethsend.py vt-host1 $ETH3_MAC "Hello host3!"


