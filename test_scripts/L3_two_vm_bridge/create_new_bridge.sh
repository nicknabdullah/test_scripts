#!/bin/bash
# create_new_bridge.sh
# usage: ./create_new_bridge.sh <bridge_name>
# example: ./create_new_bridge.sh br0

BR_NAME=$1

if [ -z "$BR_NAME" ];
then
    echo "Usage: $0 <bridge_name>"
    exit 1
fi

# check if bridge already exists
if ip link show "$BR_NAME" &>/dev/null;
then
    echo "Bridge $BR_NAME already exists."
else
    echo "Creating bridge $BR_NAME..." 
    sudo ip link add name "$BR_NAME" type bridge
    sudo ip link set "$BR_NAME" up
    echo "Bridge $BR_NAME created and UP!"
fi

# show bridge info
echo
echo "Bridge status:"
brctl show "$BR_NAME" &>/dev/null || echo "brctl not installed or bridge-utils not available"
ip addr show "$BR_NAME"
    

