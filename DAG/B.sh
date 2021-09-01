#!/bin/bash

echoerr() { echo "$@" 1>&2; }

rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database $1 --table "quetzal_EGG_1" | tr -d '[],')
if ((${#rowids[@]})); then
  echo  "Database "$1": newick formulas found in database, array is not empty, iteration possible. Creating folder phylip."
  mkdir phylip
  mkdir arlequin
  for i in $rowids
  do
    echo "Database "$1", rowid "$i": sampling s prior."
    s=$(python3 -m crumbs.sample "uniform_real" 0.00025 0.0000025)
    echo "Database "$1", rowid "$i": s = "$s"."
    echo "Database "$1", rowid "$i": about to simulate PHYLIP sequences."
    # simulate PHYLIP
    python3 -m crumbs.simulate_phylip_sequences \
    --database $1 \
    --table "quetzal_EGG_1" \
    --rowid $i\
    --sequence_size 1041  \
    --scale_tree $s \
    --output "phylip/pod_"$i".phyl"
    # If PHYLIP files looks normal
    if [ -s "phylip/pod_"$i".phyl" ]
    then 
      echo "Database "$1", rowid "$i": PHYLIP file phylip/pod_"$i".phyl exists and looks OK. Continuing to ARLEQUIN."
      python3 -m crumbs.phylip2arlequin \
      --input "phylip/pod_"$i".phyl" \
      --imap "imap.txt" \
      --output "arlequin/pod_"$i".arp"
    else
      echo "Database "$1", rowid "$i": PHYLIP file phylip/pod_"$i".phyl does not exist, or is empty. Exiting iteration with code 1."
      echoerr "Database "$1", rowid "$i": PHYLIP file phylip/pod_"$i".phyl does not exist, or is empty. Exiting iteration with code 1."
      exit 1
    fi
  done
  echo "Database "$1": compressing ARLEQUIN files."
  tar -czvf arlequin.tar.gz arlequin
  echo "Database "$1": archive arlequin.tar.gz created."
else
  echoerr "Database "$1": rowids array is empty. No newick formulas found in database. Exiting with code 1."
  exit 1
fi
