#!/bin/bash
# Check for required arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <bridge_namespace> <bridge>"
    exit 1
fi

create_bridge_namespace() {

    local ns_name="$1" #first argument = namespace name
    local br_name="$2" #second argument = bridge name

    echo "Creating bridge namespace ${ns_name} with bridge ${br_name}"

    # 1. Create a new network namespace
    ip netns add ${ns_name}
    
    # 2. Bring up the loopback interface inside the namespace
    ip netns exec ${ns_name} ip link set lo up

    # 3. Create a bridge interface inside the namespace
    ip netns exec ${ns_name} ip link add name ${br_name} type bridge 

    #. 4. Bring up the bridge interface
    ip netns exec ${ns_name} ip link set ${br_name} up  
}

# Pass the namespace name and bridge name as arguments
create_bridge_namespace "$1" "$2"
