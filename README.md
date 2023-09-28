
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Slow Etcd GRPC Requests
---

The incident type "Slow Etcd GRPC Requests" is triggered when the performance of Etcd GRPC requests slows down. This may be due to HTTP requests slowing down, and the 99th percentile exceeding 0.15s. This incident can affect the overall performance of the system, and needs to be resolved promptly.

### Parameters
```shell
export INTERFACE_NAME="PLACEHOLDER"

export NEW_NODE_COUNT="PLACEHOLDER"

export NEW_NODE_IP="PLACEHOLDER"

export CPU_LIMIT="PLACEHOLDER"

export NETWORK_LIMIT="PLACEHOLDER"

export DISK_LIMIT="PLACEHOLDER"

export MEMORY_LIMIT="PLACEHOLDER"
```

## Debug

### Check the current CPU usage
```shell
top -b -n 1 | head -n 20
```

### Check the current memory usage
```shell
free -m
```

### Check the network connections to the affected instance
```shell
ss -s
```

### Check the network traffic on the affected network interface
```shell
ifstat -i ${INTERFACE_NAME} 1
```

### Check the etcd logs for errors or warnings
```shell
journalctl -u etcd.service | tail -n 100
```

### Check the GRPC logs for errors or warnings
```shell
journalctl -u grpc.service | tail -n 100
```

### Check the Prometheus metrics for etcd and GRPC
```shell
curl -s http://localhost:9090/metrics | grep etcd | grep grpc
```

### Check the etcd cluster health
```shell
etcdctl cluster-health
```

### Check the etcd member list
```shell
etcdctl member list
```

### Check the etcd endpoint status
```shell
etcdctl endpoint status
```

### Check the etcd key space size
```shell
etcdctl endpoint fsync total
```

### Check the etcd watch counts
```shell
etcdctl watch count
```

### Check the etcd snapshot size
```shell
du -sh /var/lib/etcd/member/snap/db
```

### Resource contention on the etcd cluster.
```shell


#!/bin/bash



# Check for resource contention on the etcd cluster



# Check CPU usage

cpu_limit=${CPU_LIMIT}

cpu_usage=$(top -b -n 1 | grep etcd | awk '{print $9}')

if (( $(echo "$cpu_usage > $cpu_limit" | bc -l) )); then

    echo "CPU usage is high. Current usage is $cpu_usage%"

fi



# Check memory usage

mem_limit=${MEMORY_LIMIT}

mem_usage=$(top -b -n 1 | grep etcd | awk '{print $10}')

if (( $(echo "$mem_usage > $mem_limit" | bc -l) )); then

    echo "Memory usage is high. Current usage is $mem_usage%"

fi



# Check network throughput

net_limit=${NETWORK_LIMIT}

net_usage=$(netstat -an | grep -c etcd)

if (( $(echo "$net_usage > $net_limit" | bc -l) )); then

    echo "Network throughput is high. Current throughput is $net_usage connections"

fi



# Check disk usage

disk_limit=${DISK_LIMIT}

disk_usage=$(df -h | grep etcd | awk '{print $5}')

if (( $(echo "${disk_usage::-1} > $disk_limit" | bc -l) )); then

    echo "Disk usage is high. Current usage is $disk_usage"

fi



# Check for any locked resources

if [[ $(find /var/lib/etcd/member/wal -type f -name lock) ]]; then

    echo "Etcd cluster has locked resources"

fi




```

## Repair

### Increase the number of etcd nodes to improve the capacity of the cluster.
```shell


#!/bin/bash



# Set the number of nodes to increase the capacity of the etcd cluster.

NEW_NODE_COUNT=${NEW_NODE_COUNT}



# Get the current number of nodes in the etcd cluster.

CURRENT_NODE_COUNT=$(etcdctl member list | wc -l)



# Check if the current node count is less than the new node count.

if [ "$CURRENT_NODE_COUNT" -lt "$NEW_NODE_COUNT" ]; then

  # Calculate the number of new nodes to add.

  NODES_TO_ADD=$((NEW_NODE_COUNT - CURRENT_NODE_COUNT))



  # Loop through the number of new nodes to add.

  for i in $(seq 1 $NODES_TO_ADD); do

    # Generate a new unique name for the etcd node.

    NODE_NAME=$(uuidgen)



    # Add the new node to the etcd cluster.

    etcdctl member add "$NODE_NAME" --peer-urls="https://${NEW_NODE_IP}:2380"



    # Start the etcd service on the new node.

    systemctl start etcd

  done



  # Check the status of the etcd cluster.

  etcdctl cluster-health

fi


```