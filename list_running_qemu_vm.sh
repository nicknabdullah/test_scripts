#!/bin/bash
# list_running_qemu_vm.sh
# Lists running QEMU VMs once per VM

echo "Listing running QEMU VMs..."
echo "----------------------------------------------"
printf "%-25s %-50s %-10s %-17s %-6s\n" "VM Name" "Disk Image" "Tap" "MAC" "PID"
echo "--------------------------------------------------------------------------------------------------------"

ps -ef | grep "[q]emu-system-x86_64" | awk '
{
    pid=$2
    name=""
    hda=""
    tap=""
    mac=""
    for(i=1;i<=NF;i++){
        if($i=="-name") {name=$(i+1)}
        if($i=="-hda") {hda=$(i+1)}
        if($i ~ /ifname=/ && tap=="") {tap=substr($i,8)}
        if($i ~ /mac=/ && mac=="") {mac=substr($i,5)}
    }
    if(name!="" && !seen[name]++){
        printf "%-25s %-50s %-10s %-17s %-6s\n", name, hda, tap, mac, pid
    }
}'

