
## Overview
Contains scripts to create virtual networks using Linux namespaces, bridge, veths, router, ip, subnet, mac, etc.

## Prerequisites

- A Linux host with iproute2 (ip), bridge-utils (or support for `ip link` bridge commands), and Python 3.
- sudo/root privileges to create network namespaces and interfaces.
- Recommended packages: iproute2, iputils‑ping, python3, python3‑pip (if you need to install extra python deps).

- On Debian/Ubuntu you can install the basics with:

```bash
sudo apt update
sudo apt install -y iproute2 iputils-ping python3
```

## Make scripts executable and run
To make a script executable:
```
chmod +x script.sh
```
Then run it as root:
```
sudo ./script.sh
```
If you want to make all shell scripts in subfolders executable:
```
find . -type f -name '*.sh' -exec chmod +x {} +
```

Note: not needed to start the script with `sudo bash`, following above.

## Helper scripts

Some general purpose helper scripts.

| Script | Purpose |
|---|---|
| `clear_netns.sh` | Interactively lists and deletes Linux network namespaces found via `ip netns list`. Prompts before deleting each namespace. |
| `disable-vbox.sh` | Stops running VirtualBox VMs and services and unloads VirtualBox kernel modules so KVM can be used. |
| `enable-vbox.sh` | Reloads VirtualBox kernel modules and starts VirtualBox services after they were disabled. |
| `list_running_qemu_vm.sh` | Parses running `qemu-system-x86_64` processes and prints VM name, disk image, tap device, MAC and PID in a table format. |


### License

Free to use for learning and experimentation.