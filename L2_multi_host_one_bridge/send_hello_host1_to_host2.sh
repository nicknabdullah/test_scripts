#!/bin/bash
# send_L2_hello_from_host1_to_host2.sh

# Get host2 -> veth MAC (eg. vt-host2 is the veth of host2)
ETH2_MAC=$(ip netns exec host2 ip link show vt-host2 | awk '/ether/ {print $2}')
echo "Host2 veth MAC: $ETH2_MAC"

# Send frame from host1 veth (eg. vt-host1 is the veth of host1) to host2 veth
sudo ip netns exec host1 ./ethsend.py vt-host1 $ETH2_MAC "Hello host2!"


