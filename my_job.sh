#!/bin/bash

# prior sampling
N=$(python3 -m crumbs.sample "uniform_integer" 10 1000)
K=$(python3 -m crumbs.sample "uniform_integer" 10 1000)
r=$(python3 -m crumbs.sample "uniform_real" 1 5)
m=$(python3 -m crumbs.sample "uniform_real" 0.0 0.1)
g=$(python3 -m crumbs.sample "uniform_integer" 100 500)
p=$(python3 -m crumbs.sample "uniform_real" 0.0001 0.1)
latlon=($(python3 -m crumbs.sample "uniform_latlon" "suitability.tif" | tr -d '[],'))

# simulation
/usr/local/quetzal-EGGS/EGG1 \
--config "EGG1.conf" \
--tips "sample.csv" \
--suitability "suitability.tif" \
--output "output.db" \
--reuse 10 \
--n_loci 1 \
--lat_0 ${latlon[0]} \
--lon_0 ${latlon[1]} \
--N_0 $N \
--duration $g \
--K_suit $K \
--K_min 0 \
--K_max 1 \
--p_K $p \
--r $r \
--emigrant_rate $m

rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database "output.db" --table "quetzal_EGG_1")

for i in $rowids
do
  echo "Rowid "$i
  s=$(python3 -m crumbs.sample "uniform_real" 0.00025 0.0000025)

  python3 -m crumbs.simulate_phylip_sequences \
  --database "output.db" \
  --table "quetzal_EGG_1" \
  --rowid $i\
  --sequence_size 1041  \
  --scale_tree $s \
  --output "pods/phylip/pod_"$i".phyl"
  
  echo "Simulated: pod_"$i".phyl"  

  python3 -m crumbs.phylip2arlequin \
  --input "pods/phylip/pod_"$i".phyl" \
  --imap "imap.txt" \
  --output "pods/arlequin/pod_"$i".arp"

  echo "Phylip converted to Arlequin pod_"$i".arp"

  if [ $i -eq ${rowids[0]} ]; then
      echo "Printing headers and sumstats"
      ./arlsumstat3522_64bit "pods/arlequin/pod_"$i".arp" outSS 0 1 run_silent
   else
      echo "Printing sumstats"
      ./arlsumstat3522_64bit "pods/arlequin/pod_"$i".arp" outSS 1 0 run_silent
   fi
   rm "pods/arlequin/pod_"$i".res" -r

done

