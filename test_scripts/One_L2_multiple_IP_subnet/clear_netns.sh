#!/bin/bash
# clear_netns.sh
# Interactively deletes network namespaces

set -e

namespaces=$(ip netns list | awk '{print $1}')

if [ -z "$namespaces" ]; then
  echo "No namespaces found."
  exit 0
fi

echo "Found namespaces:"
echo "$namespaces"
echo

for ns in $namespaces; do
  read -p "Delete namespace '$ns'? [y/N]: " confirm
  case "$confirm" in
    [yY]|[yY][eE][sS])
      echo "Deleting $ns..."
      sudo ip netns del "$ns"
      ;;
    *)
      echo "Skipping $ns."
      ;;
  esac
done

echo "✅ Done."

