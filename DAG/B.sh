#!/bin/bash

echoerr() { echo "$@" 1>&2; }

rowids=($(python3 -m crumbs.get_successful_simulations_rowids --database $1 --table "quetzal_EGG_1" | tr -d '[],'))

if [[ -z "$rowids" ]]; then 
  echoerr $1": no newick formulas found in database."
  exit 1
else
  echo  $1": newick formulas found in database."
  mkdir phylip
  for i in $rowids
  do
    echo "Simulating sequence for Newick formula"$i"found in database "$1"."
    s=$(python3 -m crumbs.sample "uniform_real" 0.00025 0.0000025)
    echo "s = "$s
    python3 -m crumbs.simulate_phylip_sequences \
    --database $1 \
    --table "quetzal_EGG_1" \
    --rowid $i\
    --sequence_size 1041  \
    --scale_tree $s \
    --output "phylip/pod_"$i".phyl"
    
    echo "Databse "$1", rowid "$i": phylip/pod_"$i".phyl simulated"
  done
  tar -czf phylip.tar.gz phylip
  echo "Databse "$1", phylip.tar.gz compressed."
fi
