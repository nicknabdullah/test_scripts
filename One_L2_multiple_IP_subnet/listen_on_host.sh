#!/usr/bin/env bash
# ===============================================================
# Script Name: listen_ping_on_host.sh
#
# Usage:
#   ./listen_ping_on_host.sh <host_name> <host_ifname>
#
# Example:
#   ./listen_ping_on_host.sh host10 eth10
#
# Captures ICMP (ping) packets inside the given network namespace.
# Uses nsenter for reliable capture on veth interfaces.
# ===============================================================

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <host_name> <host_ifname>"
  exit 1
fi

NAMESPACE="$1"
INTERFACE="$2"

NS_PATH="/var/run/netns/$NAMESPACE"
if [ ! -e "$NS_PATH" ]; then
  echo "Namespace file $NS_PATH does not exist. Did you create $NAMESPACE?"
  exit 2
fi

echo "Listening for ping (ICMP) in namespace '$NAMESPACE' on interface '$INTERFACE'"
echo "Press Ctrl-C to stop."
sudo nsenter --net=/var/run/netns/$NAMESPACE tcpdump -i $INTERFACE -n -vv -X


