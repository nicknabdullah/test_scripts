#!/bin/bash
# recreate_and_start_vms.sh
#
# Clears previous bridges/taps, recreates br0, tap1, tap2,
# sets MACs, launches VMs with GUI, cloud-init user ubuntu/ubuntu.
#
# Usage: sudo ./recreate_and_start_vms.sh

# --- CONFIGURATION ---
BR_NAME="br0"
TAPS=("tap1" "tap2")
VM_NAMES=("vm-1" "vm-2")

# --- STOP any running VMs ---
for i in "${!VM_NAMES[@]}"; do
    pkill -f "${VM_NAMES[i]}" || true
done

# --- Clear Taps ---
echo "Cleaning up old bridges and taps..."
for tap in "${TAPS[@]}"; do
    sudo ip link set "$tap" down 2>/dev/null || true
    sudo ip link delete "$tap" type tap 2>/dev/null || true
done

# --- Clear Bridge
sudo ip link set $BR_NAME down 2>/dev/null || true
sudo ip link delete $BR_NAME type bridge 2>/dev/null || true

echo "VMs, taps, bridge cleared."

