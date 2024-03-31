# Restart ssh
service ssh restart && bash

# Make sure env is activated
conda activate dgl-dev-cpu
conda env list
which python3
