#!/bin/bash
# Disable VirtualBox so KVM can be used

echo "[INFO] Stopping VirtualBox VMs..."
VBoxManage list runningvms | while read -r vmline; do
    vm=$(echo "$vmline" | cut -d'"' -f2)
    echo " - Powering off $vm"
    VBoxManage controlvm "$vm" poweroff
done

echo "[INFO] Stopping VirtualBox services..."
sudo systemctl stop vboxdrv.service 2>/dev/null
sudo systemctl stop vboxautostart-service.service 2>/dev/null
sudo systemctl stop vboxballoonctrl-service.service 2>/dev/null
sudo systemctl stop vboxweb-service.service 2>/dev/null

echo "[INFO] Unloading VirtualBox kernel modules..."
sudo modprobe -r vboxdrv vboxnetflt vboxnetadp vboxpci 2>/dev/null

echo "[DONE] VirtualBox disabled. You can now use KVM."

