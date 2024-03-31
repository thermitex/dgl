#!/bin/sh

BATCH_SIZE=${1:-"1000"}
STRAG_PER_SAMPLE=${2:-"0.00001"}
BALANCED=${3:-"bal"}
GRAPH_NAME=${4:-"ogbn-products"}

python3 /dgl/tools/launch_unbalanced.py \
--workspace ~/workspace/ \
--num_trainers 1 \
--num_samplers 0 \
--straggler_list 0 1 1 1 \
--num_servers 1 \
--num_omp_threads 2 \
--extra_envs DGL_STRAG_PER_SAMPLE=${STRAG_PER_SAMPLE} \
--part_config data_${GRAPH_NAME}_${BALANCED}/${GRAPH_NAME}.json \
--ip_config ip_config.txt \
"/opt/conda/envs/dgl-dev-cpu/bin/python3 /dgl/examples/distributed/graphsage/node_classification.py --graph_name ${GRAPH_NAME} --ip_config ip_config.txt --num_epochs 50 --eval_every 1 --log_every 1 --batch_size ${BATCH_SIZE}" > graphsage_${GRAPH_NAME}_${BALANCED}_metis_0.75_bs${BATCH_SIZE}_st${STRAG_PER_SAMPLE}.log
