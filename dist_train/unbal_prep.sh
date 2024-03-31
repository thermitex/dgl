#!/bin/sh

SELF_IP=${1:-""}
GRAPH_NAME=${2:-"ogbn-products"}
NUM_MACHINES=${3:-"4"}

data="data_${GRAPH_NAME}_unbal"

if [ ! -d "${data}/" ]; then
  echo "Data does not exist, partition graph first"
  python3 /dgl/examples/distributed/graphsage/partition_graph.py --dataset ${GRAPH_NAME} --num_parts ${NUM_MACHINES} --balance_train --balance_edges --part_weights 1.5 1.5 0.5 0.5
fi

mv data ${data}

echo "Copy data to all machines"
ips=$(cat ip_config.txt)
for ip in $ips
do 
  echo "Copying to ${ip}"
  if [ "$ip" != "${SELF_IP}" ]; then
    ssh -o StrictHostKeyChecking=no $ip 'mkdir -p ~/workspace'
    scp -r ${data}/ root@$ip:~/workspace/${data}
    scp ip_config.txt root@$ip:~/workspace/ip_config.txt
  fi
done