#!/bin/bash

DEST=param_table.txt
counter=1
for FILE in output_files/param_table-*txt
do
  echo $FILE
  # remove extra blank lines
  sed -i '/^$/d' $FILE
  if [ $counter -eq 1 ]; then
      cat "$FILE" >>"$DEST"
  else
    sed -e'1d' $FILE >>"$DEST"
  fi
  let "counter+=1"
done

