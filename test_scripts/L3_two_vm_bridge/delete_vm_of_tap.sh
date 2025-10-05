#!/bin/bash
# delete_vm_of_tap.sh
# Usage: ./delete_vm_of_tap.sh <tap_interface_name>

set -x

TAP_IF=$1

if [ -z "$TAP_IF" ]; then
    echo "Usage: $0 <tap_interface_name>"
    exit 1
fi

# Find QEMU processes that use this TAP interface
PIDS=$(pgrep -f "qemu.*$TAP_IF")

if [ -n "$PIDS" ]; then
    echo "Stopping VM process(es) for TAP $TAP_IF: $PIDS"
    for PID in $PIDS; do
        sudo kill "$PID"
    done
    # Give processes a moment to terminate
    sleep 1
else
    echo "No VM process found for TAP $TAP_IF."
fi

# Remove TAP interface if it exists
if ip link show "$TAP_IF" &>/dev/null; then
    echo "Removing TAP interface $TAP_IF..."
    sudo ip link set "$TAP_IF" down
    sudo ip tuntap del dev "$TAP_IF" mode tap
    echo "TAP interface $TAP_IF removed."
else
    echo "TAP interface $TAP_IF does not exist."
fi

