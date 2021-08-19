#!/bin/bash

tar -xzf phylip.tar.gz
mkdir arlequin

rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database "output.db" --table "quetzal_EGG_1")

for i in $rowids
do
  
  python3 -m crumbs.phylip2arlequin \
  --input "phylip/pod_"$i".phyl" \
  --imap "imap.txt" \
  --output "arlequin/pod_"$i".arp"

done

tar -czf arlequin.tar.gz arlequin
