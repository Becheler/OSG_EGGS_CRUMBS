#!/bin/bash

DEST=params_table.txt
FILES= ls output_files/param_table-*.txt

counter=1
echo "" >$DEST
for FILE in $FILES
do
  if [ $counter -eq 1 ]; then
      $FILE >>$DEST
    else
      sed -e'1d' $FILE >>$DEST
    fi
  let "counter+=1"
done

