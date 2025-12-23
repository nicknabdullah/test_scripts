#!/bin/bash
# Enable VirtualBox after disabling it

echo "[INFO] Reloading VirtualBox kernel modules..."
sudo modprobe vboxdrv
sudo modprobe vboxnetflt
sudo modprobe vboxnetadp
sudo modprobe vboxpci 2>/dev/null

echo "[INFO] Starting VirtualBox services..."
sudo systemctl start vboxdrv.service 2>/dev/null
sudo systemctl start vboxautostart-service.service 2>/dev/null
sudo systemctl start vboxballoonctrl-service.service 2>/dev/null
sudo systemctl start vboxweb-service.service 2>/dev/null

echo "[DONE] VirtualBox re-enabled. You can now run VMs again."

