

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