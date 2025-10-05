#!/bin/bash
#show tcpdump in host2
echo "Listening on host2 veth (vt-host2)..."
sudo ip netns exec host2 tcpdump -i vt-host2 ether proto 0x7a05 -vv -l -A
