#!/bin/sh

# Submits n jobs to the torque queing system

for i in {1..29}
do
  let var1=10*$i;
  echo 'Start Job ' $i 'wait for: ' $var1 's'
  qsub -v var="$var1" submit_jobs.sh
done
