#!/bin/bash

rowids=$(python3 -m crumbs.get_successful_simulations_rowids --database "output.db" --table "quetzal_EGG_1")

for i in $rowids
do
  
  python3 -m crumbs.phylip2arlequin \
  --input "pods/phylip/pod_"$i".phyl" \
  --imap "imap.txt" \
  --output "pods/arlequin/pod_"$i".arp"

done
