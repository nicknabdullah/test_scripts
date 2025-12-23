#!/bin/bash

# List all namespaces
NAMESPACES=$(sudo ip netns list | awk '{print $1}')

# Check if any namespaces were found
if [ -z "$NAMESPACES" ]; then
    echo "No network namespaces found to delete."
    exit 0
fi

echo "Found the following namespaces to delete:"
echo "$NAMESPACES"

# Loop through each namespace and delete it
for ns in $NAMESPACES; do
    echo "Deleting namespace: $ns"
    sudo ip netns del "$ns"
done

echo "All listed namespaces have been deleted."
