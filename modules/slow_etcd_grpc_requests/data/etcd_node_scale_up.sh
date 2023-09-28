

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