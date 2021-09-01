#!/bin/bash

echoerr() { echo "$@" 1>&2; }

rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database $1 --table "quetzal_EGG_1" | tr -d '[],')
if ((${#rowids[@]})); then
  echo  $1": newick formulas found in database, array is not empty."
  mkdir phylip
  for i in $rowids
  do
    echo "Rowid "$i" in database "$1": sampling s prior."
    s=$(python3 -m crumbs.sample "uniform_real" 0.00025 0.0000025)
    echo "Rowid "$i" in database "$1": s = "$s"."
    echo "Rowid "$i" in database "$1": about to simulate PHYLIP sequences."    
    python3 -m crumbs.simulate_phylip_sequences \
    --database $1 \
    --table "quetzal_EGG_1" \
    --rowid $i\
    --sequence_size 1041  \
    --scale_tree $s \
    --output "phylip/pod_"$i".phyl"
    if [ -s "phylip/pod_"$i".phyl" ]
    then 
      echo "Rowid "$i" in database "$1": PHYLIP file phylip/pod_"$i".phyl exists and is not empty "
    else
      echoerr "Rowid "$i" in database "$1": PHYLIP file phylip/pod_"$i".phyl does not exist, or is empty "
      exit 1
    fi
    echo "Rowid "$i" in database "$1": phylip/pod_"$i".phyl simulated."
  done
  echo "Database "$1", compressing PHYLIP files."
  tar -czvf phylip.tar.gz phylip
  echo "Database "$1", phylip.tar.gz created."
else
  echoerr $1": rowids array is empty: no newick formulas found in database."
  exit 1
fi
