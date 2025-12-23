#!/bin/bash
#show tcpdump in host3
echo "Listening on host3 veth (vt-host3)..."
sudo ip netns exec host3 tcpdump -i vt-host3 ether proto 0x7a05 -vv -l -A
