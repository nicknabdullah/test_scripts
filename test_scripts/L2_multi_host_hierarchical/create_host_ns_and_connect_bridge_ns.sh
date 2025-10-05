#!/bin/bash
if [ $# -lt 4 ]; then
    echo "Usage: $0 <host_namespace> <host_ifname> <bridge_namespace> <bridge_name>"
    exit 1
fi
    
create_host_ns_and_connect_bridge_ns() {

    local host_namespace="$1"       # e.g. host10 (host namespace name)
    local host_ifname="$2"          # e.g. eth10 (interface/veth name inside host namespace)
    local bridge_namespace="$3"     # e.g. bridge1 (bridge namespace name)
    local bridge_name="$4"          # e.g. br1 (bridge name inside bridge namespace)
    local bridge_ifname="${host_ifname}-${bridge_namespace}"  # e.g. eth10-bridge1 (interface/veth name inside bridge namespace)

    echo "Creating end host ${host_namespace}/${host_ifname} and connecting to ${bridge_namespace}/${bridge_name}"

    # 1. Create host namespace
    ip netns add "${host_namespace}"
    
    # 2. Bring up loopback in host namespace
    ip netns exec "${host_namespace}" ip link set lo up

    # 3. Create veth pair
    ip link add "${host_ifname}" type veth peer name "${bridge_ifname}"

    # 4. Move host end to host namespace
    ip link set "${host_ifname}" netns "${host_namespace}"

    # 5. Move bridge end to bridge namespace
    ip link set "${bridge_ifname}" netns "${bridge_namespace}"

    # 6. Bring both ends up
    ip netns exec "${host_namespace}" ip link set "${host_ifname}" up
    ip netns exec "${bridge_namespace}" ip link set "${bridge_ifname}" up
    
    # 7. Attach bridge-side veth to the bridge
    ip netns exec "${bridge_namespace}" ip link set "${bridge_ifname}" master "${bridge_name}"
}

# Run function with provided arguments
create_host_ns_and_connect_bridge_ns "$1" "$2" "$3" "$4"
