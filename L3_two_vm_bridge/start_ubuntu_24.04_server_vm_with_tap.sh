#!/bin/bash
# download_start_ubuntu_24.04_vm_with_tap.sh
#
# This script creates and starts an Ubuntu 24.04 QEMU VM with a fresh disk overlay
# on a TAP interface, configured with cloud-init for a console login.
#
# Usage:
#   sudo ./download_start_ubuntu_24.04_vm_with_tap.sh <vm_name> <tap_name> <vm_index>
#
# Arguments:
#   <vm_name>  : The name for the new VM (e.g., my-server-1). This will be used
#                to name the VM disk and hostname.
#   <tap_name> : Name of the TAP interface to use (e.g., tap0, tap1).
#                This interface will be created and attached to br0.
#   <vm_index> : Integer index used to assign a dynamic static IP address.
#
# Example:
#   sudo ./download_start_ubuntu_24.04_vm_with_tap.sh my_vm1 tap1 1

VM_NAME="$1"
TAP_IF="$2"
VM_INDEX="$3"

# Hardcoded paths and configurations
BASE_IMG_NAME="noble-server-cloudimg-amd64.img"
VM_DIR="/home/surface/Qemu-VMs/noble-server-cloudimg-amd64"
BASE_IMG="${VM_DIR}/${BASE_IMG_NAME}"
VM_DISK="${VM_DIR}/ubuntu-24.04-server-cloudimg-amd64_${VM_NAME}.qcow2"
USERNAME="ubuntu"
PASSWORD="ubuntu"
MEMORY="2048M"
CPUS="2"

# Base subnet for VMs
SUBNET="192.168.100"
GATEWAY="${SUBNET}.1"
NETMASK="24"

# Check arguments
if [ -z "$VM_NAME" ] || [ -z "$TAP_IF" ] || [ -z "$VM_INDEX" ]; then
    echo "Usage: $0 <vm_name> <tap_name> <vm_index>"
    exit 1
fi

# Determine the actual user's home if running via sudo
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

# --- Step 1: Create VM directory (if not present) and download the cloud image ---
if [ ! -d "$VM_DIR" ]; then
    echo "Creating VM directory '$VM_DIR'..."
    mkdir -p "$VM_DIR"
fi

if [ ! -f "$BASE_IMG" ]; then
    echo "Downloading Ubuntu 24.04 cloud image to '$VM_DIR'..."
    wget "https://cloud-images.ubuntu.com/noble/current/${BASE_IMG_NAME}" -O "$BASE_IMG"
fi

# --- Step 2: Create a fresh overlay disk ---
if [ -f "$VM_DISK" ]; then
    echo "Removing old overlay disk '$VM_DISK'..."
    rm -f "$VM_DISK"
fi
echo "Creating fresh qcow2 overlay disk for VM '$VM_NAME'..."
qemu-img create -f qcow2 -F qcow2 -b "$BASE_IMG" "$VM_DISK"

# --- Step 3: Generate a random MAC address ---
MAC="52:54:00$(openssl rand -hex 3 | sed 's/\(..\)/:\1/g')"
echo "Generated MAC: $MAC"

# --- Step 4: Configure the network TAP interface ---
if ! ip link show "$TAP_IF" &>/dev/null; then
    echo "Creating TAP interface '$TAP_IF'..."
    sudo ip tuntap add dev "$TAP_IF" mode tap user "$SUDO_USER"
else
    echo "TAP interface '$TAP_IF' already exists."
fi
sudo ip link set "$TAP_IF" up
sudo ip link set "$TAP_IF" master br0
echo "TAP interface '$TAP_IF' is up and attached to br0."

# --- Step 5: Generate cloud-init configuration files ---
VM_IP="${SUBNET}.$((100 + VM_INDEX))"

USER_DATA=$(mktemp /tmp/user-data.XXXX.yaml)
cat > "$USER_DATA" <<EOF
#cloud-config
users:
  - name: $USERNAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    passwd: "$PASSWORD"
    expire_passwd: false
ssh_pwauth: true
chpasswd:
  list: |
    ${USERNAME}:${PASSWORD}
  expire: false
network:
  version: 2
  ethernets:
    ens3:
      dhcp4: false
      addresses:
        - ${VM_IP}/${NETMASK}
      routes:
        - to: default
          via: ${GATEWAY}
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
EOF

META_DATA=$(mktemp /tmp/meta-data.XXXX)
cat > "$META_DATA" <<EOF
instance-id: iid-$VM_NAME
local-hostname: $VM_NAME
EOF

SEED_IMG=$(mktemp /tmp/seed.XXXX.img)
cloud-localds "$SEED_IMG" "$USER_DATA" "$META_DATA"

# --- Step 6: Start the VM ---
echo "Starting VM '$VM_NAME' in GUI mode with static IP $VM_IP..."
sudo qemu-system-x86_64 \
    -name "$VM_NAME" \
    -m "$MEMORY" \
    -smp "$CPUS" \
    -drive if=virtio,file="$VM_DISK",format=qcow2 \
    -cdrom "$SEED_IMG" \
    -netdev tap,id=net0,ifname="$TAP_IF",script=no,downscript=no \
    -device virtio-net-pci,netdev=net0,mac="$MAC" \
    -display gtk \
    -serial file:vm_boot.log \
    -enable-kvm \
    -boot c

# --- Step 7: Cleanup temporary files ---
rm -f "$USER_DATA" "$META_DATA" "$SEED_IMG"

if [ $? -eq 0 ]; then
    echo "--------------------------------------------------------"
    echo "VM '$VM_NAME' started successfully."
    echo "You can log in to the graphical console after the boot process is complete."
    echo "Username: $USERNAME"
    echo "Password: $PASSWORD"
    echo "--------------------------------------------------------"
fi
