#!/bin/bash

# Defining a small function in case of error
echoerr() { echo "$@" 1>&2; }

# Iterate throughs rows in the database argument
echo "Database "$1": --------------------------------------------------------------------------"
counter=1
rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database $1 --table "quetzal_EGG_1" | tr -d '[],')
if (( ${#rowids[@]} != 0 )); then
  # Iterable rows
  echo  "Database "$1": newick formulas found in database, array is not empty, iteration possible."

  for i in $rowids
  do

    # Sample prior
    echo "Database "$1", rowid "$i": sampling s prior."

    s=$(python3 -m crumbs.sample "uniform_real" 0.00025 0.0000025)

    #s=0.000000005
    echo "Database "$1", rowid "$i": s = "$s"."
    echo "Database "$1", rowid "$i": simulating PHYLIP sequences in folder </phylip>."
    
    # Simulate genetic in data PHYLIP format
    mkdir -p phylip

    python3 -m crumbs.simulate_phylip_sequences \
    --database $1 \
    --table "quetzal_EGG_1" \
    --rowid $i\
    --sequence_size 1041  \
    --scale_tree $s \
    --output "phylip/pod_"$i".phyl"

    # If PHYLIP files looks normal
    cat phylip/pod_"$i".phyl
    head -n -1 phylip/pod_"$i".phyl > temp.txt ; mv temp.txt phylip/pod_"$i".phyl
    cat phylip/pod_"$i".phyl
    if [ -s "phylip/pod_"$i".phyl" ]; then
      echo "Database "$1", rowid "$i": PHYLIP file phylip/pod_"$i".phyl exists and looks legit. Creating folder </arlequin> for format conversion."
      
      # Converts to ARLEQUIN format
      mkdir -p arlequin

      python3 -m crumbs.phylip2arlequin \
      --input "phylip/pod_"$i".phyl" \
      --imap "imap.txt" \
      --output "arlequin/pod_"$i".arp"

      cat arlequin/pod_"$i".arp
      echo "Database "$1": computing SUMSTATS."

      # Compute summary statistics
      if [ $counter -eq 1 ]; then

        # Should include header (sumstat names) in the table
        ./arlsumstat3522_64bit "arlequin/pod_"$i".arp" outSS 0 1 run_silent

        # Retrieve parameters from database
        python3 -m crumbs.retrieve_parameters \
        --database $1 \
        --table "quetzal_EGG_1" \
        --rowid $i \
        --header \
        >>param_table.txt

      else

        # Just append the stats in the table
        ./arlsumstat3522_64bit "arlequin/pod_"$i".arp" outSS 1 0 run_silent
        python3 -m crumbs.retrieve_parameters \
        --database $1 \
        --table "quetzal_EGG_1" \
        --rowid $i \
        --no-header \
        >>param_table.txt
      fi
      let "counter+=1"
    else
      echo "Database "$1", rowid "$i": PHYLIP file phylip/pod_"$i".phyl does not exist, or is empty. Exiting iteration with code 1."
      echoerr "Database "$1", rowid "$i": PHYLIP file phylip/pod_"$i".phyl does not exist, or is empty. Exiting iteration with code 1."
      exit 1
    fi
  done # all rowids have be iterated
else
  echoerr "Database "$1": rowids array is empty. No newick formulas found in database. Exiting with code 1."
  exit 1
fi
