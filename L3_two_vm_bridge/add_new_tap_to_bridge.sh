#!/bin/bash
#
# Usage:
#   ./attach_tap_to_bridge.sh <tap_name> <bridge_name>
#
# Example:
#   ./attach_tap_to_bridge.sh tap0 br0
#
# Description:
#   Creates a TAP interface (if not already existing), brings it up,
#   and attaches it to the specified bridge.

set -x   # Enable debug mode to print each command before execution

# --- Argument check ---
if [ $# -lt 2 ]; then
    echo "Usage: $0 <tap_name> <bridge_name>"
    exit 1
fi

create_bridge() {

    local tap_name="$1"       # 1st argument = TAP interface name  (e.g. tap0)
    local bridge_name="$2"    # 2nd argument = bridge name         (e.g. br0)

    echo "Attaching TAP interface '${tap_name}' to bridge '${bridge_name}'"

    # --- 1. Create TAP interface owned by current user ---
    # The 'ip tuntap add' command creates a virtual TAP interface.
    # 'mode tap' specifies it's a Layer 2 interface.
    # 'user $(whoami)' ensures the current user owns it.
    ip tuntap add "${tap_name}" mode tap user "$(whoami)"

    # --- 2. Bring the TAP interface up ---
    ip link set "${tap_name}" up
    sleep 0.5s

    # --- 3. Attach the TAP interface to the given bridge ---
    ip link set "${tap_name}" master "${bridge_name}"

    echo "TAP interface '${tap_name}' successfully attached to bridge '${bridge_name}'"
}

# --- Call the function with provided arguments ---
create_bridge "$1" "$2"

