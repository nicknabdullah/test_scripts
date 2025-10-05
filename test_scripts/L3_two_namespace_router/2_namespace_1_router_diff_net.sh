#!/bin/bash

# --- 1. Create 2 namespace and 1 router ---
echo "1. Creating namespaces... red, blue, and router"
sudo ip netns add red
sudo ip netns add blue
sudo ip netns add router

# --- 2. Create veth pairs ---
echo "2. Creating veth pairs..."
sudo ip link add veth-red type veth peer name veth-red-rt
sudo ip link add veth-blue type veth peer name veth-blue-rt

# --- 3. Attach veths to namespace and router ---
echo "3. Attach the cables to ns and router"
sudo ip link set veth-red netns red
sudo ip link set veth-red-rt netns router
sudo ip link set veth-blue netns blue
sudo ip link set veth-blue-rt netns router

# --- 4. Configure router ---
echo "4. Configuring router..."

echo "- Assign IP addressess to router's interfaces"
sudo ip netns exec router ip addr add 192.168.1.1/24 dev veth-red-rt
sudo ip netns exec router ip addr add 192.168.2.1/24 dev veth-blue-rt

echo "- Bring the interfaces UP"
sudo ip netns exec router ip link set veth-red-rt up
sudo ip netns exec router ip link set veth-blue-rt up

echo -e "- Enable IP forwarding (this makes it a router)"
sudo ip netns exec router sysctl -w net.ipv4.ip_forward=1

echo -e "- Enable loopback interface (often needed for services)"   
sudo ip netns exec router ip link set lo up

# --- 5. Configure the RED namespace ---
echo "5. Configure the RED namespace"
echo "- Assign IP"
sudo ip netns exec red ip addr add 192.168.1.2/24 dev veth-red

echo "- Bring veth-red UP"
sudo ip netns exec red ip link set veth-red up

echo "- Set default gateway to router's interface"
sudo ip netns exec red ip route add default via 192.168.1.1

echo "- Set loopback"
sudo ip netns exec red ip link set lo up

# --- 6. Configure BLUE namespace --- 
echo "6. Configure the BLUE namespace"

echo "- Assign IP"
sudo ip netns exec blue ip addr add 192.168.2.2/24 dev veth-blue

echo "- Bring veth-blue UP"
sudo ip netns exec blue ip link set veth-blue up

echo "- Set default gateway to the router's interface"
sudo ip netns exec blue ip route add default via 192.168.2.1

echo "- Set loopback"
sudo ip netns exec blue ip link set lo up

# --- 7. Test the configuration ---
echo "Testing connectivity..."
echo "Pinging router from red namespace:"
sudo ip netns exec red ping -c 2 192.168.1.1
echo "Pinging router from blue namespace:"
sudo ip netns exec blue ping -c 2 192.168.2.1
echo "Pinging blue from red namespace (through the router!):"
sudo ip netns exec red ping -c 2 192.168.2.2

echo "Lab setup complete!"
