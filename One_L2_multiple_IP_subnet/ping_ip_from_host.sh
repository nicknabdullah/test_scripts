#!/bin/bash

# Usage:
#   ./ping_ip_from_host.sh <source-hostname> <target-ip> <ping-count>
# Example:
#   ./ping_ip_from_host.sh host20 192.168.1.22 3

# Check for arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source-hostname> <target-ip> <ping-count>"
    exit 1
fi

SOURCE_HOST="$1"
TARGET_IP="$2"
PING_COUNT="$3"

# Function to ping an IP from a given host namespace
ping_ip() {
    local src_host="$1"
    local dest_ip="$2"
    local ping_count="$3"

    echo "Pinging $dest_ip from $src_host..."
    nsenter --net="/var/run/netns/$src_host" ping "$dest_ip" -c "$ping_count"
}

# Call the function
ping_ip "$SOURCE_HOST" "$TARGET_IP" "$PING_COUNT"

