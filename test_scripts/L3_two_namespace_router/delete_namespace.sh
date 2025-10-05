#!/bin/bash

# Check if any namespace names were provided as arguments
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <namespace1> [<namespace2> ...]"
    exit 1
fi

# Loop through each provided namespace name
for ns in "$@"; do
    echo "Attempting to delete namespace: $ns"

    # Execute the command and redirect error output to a temporary file
    sudo ip netns del "$ns" 2> /tmp/ip_del_error.log

    # Capture the exit code of the last command
    EXIT_CODE=$?

    # Check the exit code and provide feedback
    if [ "$EXIT_CODE" -eq 0 ]; then
        echo "Successfully deleted namespace: $ns"
    else
        echo "Error: Could not delete namespace: $ns" >&2
        echo "The error was: $(cat /tmp/ip_del_error.log)" >&2
    fi

    # Clean up the temporary file
    rm -f /tmp/ip_del_error.log
done
