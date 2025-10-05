#!/bin/bash
if [ $# -lt 3 ]; then
    echo "Usage: $0 <host_namespace> <bridge_namespace> <bridge_name>"
    exit 1
fi
    
create_host_ns_and_connect_bridge_ns() {

    local host_namespace="$1"       #1st argument = host namespace name           e.g. host1
    local host_veth="vt-$1"       #host veth name                                 e.g. vt-host1
    local bridge_namespace="$2"     #2nd argument = bridge namespace name         e.g. nsbr0
    local bridge_veth="vt-$1-$2"  #bridge veth name                               e.g. vt-host1-nsbr0     
    local bridge_name="$3"          #3rd argument = bridge inside bridge namespace  e.g. br0

    echo "Creating end host ${host_namespace}/${host_veth}"

    # 1. Create a new network namespace
    ip netns add ${host_namespace}
    
    # 2. Bring up the loopback interface inside the namespace
    ip netns exec ${host_namespace} ip link set lo up

    # 3. Create a veth pair
    ip link add ${host_veth} type veth peer name ${bridge_veth}

    # 4. Move host end of the veth pair into the host namespace
    ip link set ${host_veth} netns ${host_namespace}

    # 5. Move bridge end of the veth pair into the bridge namespace
    ip link set ${bridge_veth} netns ${bridge_namespace}

    # 6. Bring up the veths
    ip netns exec ${host_namespace} ip link set ${host_veth} up
    ip netns exec ${bridge_namespace} ip link set ${bridge_veth} up
    
    # 7. Attach the bridge end of the veth pair to the bridge
    ip netns exec ${bridge_namespace} ip link set ${bridge_veth} master ${bridge_name}
}

# Pass the arguments to the function
create_host_ns_and_connect_bridge_ns "$1" "$2" "$3"
