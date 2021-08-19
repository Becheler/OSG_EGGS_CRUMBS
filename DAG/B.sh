#!/bin/bash

rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database "output.db" --table "quetzal_EGG_1")

for i in $rowids
do
  s=$(python3 -m crumbs.sample "uniform_real" 0.00025 0.0000025)

  python3 -m crumbs.simulate_phylip_sequences \
  --database "output.db" \
  --table "quetzal_EGG_1" \
  --rowid $i\
  --sequence_size 1041  \
  --scale_tree $s \
  --output "pods/phylip/pod_"$i".phyl"

done
