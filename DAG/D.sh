#!/bin/bash

tar -xzf arlequin.tar.gz

rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database "output.db" --table "quetzal_EGG_1")

for i in $rowids
do

  if [ $i -eq ${rowids[0]} ]; then
      ./arlsumstat3522_64bit "arlequin/pod_"$i".arp" outSS 0 1 run_silent
   else
      ./arlsumstat3522_64bit "arlequin/pod_"$i".arp" outSS 1 0 run_silent
   fi

done
