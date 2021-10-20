#!/bin/bash

# takes 1 argument, the number of simulations
for i in $(seq "$1") 
do
   echo "JOB A$i src/DAG/A.condor"
   echo "VARS A$i i=\"$i\""
   echo "JOB B$i src/DAG/B.condor"
   echo "VARS B$i i=\"$i\""
   echo "PARENT A$i CHILD B$i"
   echo "Retry A$i 100"
done
