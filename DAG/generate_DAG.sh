#!/bin/bash

for i in {1..5}
do
   echo "JOB A$i A.condor"
   echo "VARS A$i i=\"$i\""
   echo "JOB B$i B.condor"
   echo "VARS B$i i=\"$i\""
   echo "JOB C$i C.condor"
   echo "VARS C$i i=\"$i\""
   echo "JOB D$i D.condor"
   echo "VARS D$i i=\"$i\""
   echo "PARENT A$i CHILD B$i"
   echo "PARENT B$i CHILD C$i"
   echo "PARENT C$i CHILD D$i"
done
