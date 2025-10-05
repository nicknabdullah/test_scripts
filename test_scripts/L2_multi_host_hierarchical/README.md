# L2 hierarchical network: Bridge of bridges  

![L2 layered network](./pic.png)



- Creating multiple bridges with multiple host namespaces in each bridge.
- Creating a hierarchy, by connecting above to a higher-level bridge
- Sending/receiving raw Ethernet frames between all connected hosts.

| File                                      | Description                                                                            |
| ----------------------------------------- | -------------------------------------------------------------------------------------- |
| `create_bridge_namespace.sh`              | Create a bridge inside a dedicated namespace (the L2 fabric).                          |
| `create_host_ns_and_connect_bridge_ns.sh` | Create host namespaces, veth pairs, and attach them to a bridge namespace.             |
| `connect_bridges.sh`                      | Helper to connect multiple bridges or namespaces.        |
| `listen_to_msg_on_host.sh`                | Run inside a host namespace to listen for incoming Ethernet frames or example traffic. |
| `ethsend.py`                              | Small Python helper to craft and send raw Ethernet frames (used by the send scripts).  |
| `send_hello_src_host_to_dst_host.sh`      | Sends a small hello message from one host namespace to another.    |
| `send_hello_to_all_macs.sh`               | Broadcasts a hello to all MACs on the bridge.                      |
| `clear_netns.sh`                          | Tear down everything created by the examples: deletes namespaces, veths, and bridges.  |

Files you may also see while experimenting are small helper logs or screenshots and are not required to run the examples.

## Typical quick workflow

1. Create 2 bridge namespaces -> **bridge1** & **bridge2**

```bash
sudo bash create_bridge_namespace.sh bridge1 br1
sudo bash create_bridge_namespace.sh bridge2 br2
```

2. Create host namespaces and connect them to the **bridge1**

```bash
sudo bash create_host_ns_and_connect_bridge_ns.sh host10 eth10 bridge1 br1
sudo bash create_host_ns_and_connect_bridge_ns.sh host11 eth11 bridge1 br1
```

3. Create host namespaces and connect them to the **bridge2**

```bash
sudo bash create_host_ns_and_connect_bridge_ns.sh host20 eth20 bridge2 br2
sudo bash create_host_ns_and_connect_bridge_ns.sh host21 eth21 bridge2 br2
```

4. Create a higher-layer **bridge3**

```bash
sudo bash create_bridge_namespace.sh bridge3 br3
```

5. Connect lower-layer bridge1, bridge2 with higher-layer **bridge3**

```bash
sudo bash connect_bridges.sh bridge1 br1 bridge3 br3
sudo bash connect_bridges.sh bridge2 br2 bridge3 br3
```

6. In separate terminals (or using tmux), start listeners inside all host namespaces

```bash
# from your normal shell
sudo ./listen_to_msg_on_host.sh host10 eth10
sudo ./listen_to_msg_on_host.sh host11 eth11
sudo ./listen_to_msg_on_host.sh host20 eth20
sudo ./listen_to_msg_on_host.sh host21 eth21
```

7. Send a hello from one host to another 

```bash
sudo bash send_hello_src_host_to_dst_host.sh host10 eth10 host20 eth20
```

Or broadcast to everyone on the bridge:

```bash
sudo bash send_hello_to_all_macs.sh host10 eth10
```

## Cleanup

When finished, run:

```bash
sudo bash clear_netns.sh
```

This removes created namespaces, veth pairs, and the bridge namespace created by the examples.
