#!/bin/bash
# delete_bridge.sh
# usage: ./delete_bridge.sh <bridge_name>

BR_NAME=$1

if [ -z "$BR_NAME" ];
then
    echo "Usage: $0 <bridge_name>"
    exit
fi

# check if bridge exists
if ip link show "$BR_NAME" &>/dev/null; 
then
    echo "Deleting bridge $BR_NAME..."

    # bring the bridge down
    sudo ip link set "$BR_NAME" down

    # delete the bridge
    sudo ip link delete "$BR_NAME" type bridge

    echo "Bridge $BR_NAME deleted!"
else
    echo "Bridge $BR_NAME does not exist."
fi
