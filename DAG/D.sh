#!/bin/bash

rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database "output.db" --table "quetzal_EGG_1")

for i in $rowids
do

  if [ $i -eq ${rowids[0]} ]; then
      ./arlsumstat3522_64bit "pods/arlequin/pod_"$i".arp" outSS 0 1 run_silent
   else
      ./arlsumstat3522_64bit "pods/arlequin/pod_"$i".arp" outSS 1 0 run_silent
   fi
   rm "pods/arlequin/pod_"$i".res" -r

done
