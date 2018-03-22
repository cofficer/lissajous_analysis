#!/bin/sh

# Submits n jobs to the torque queing system

for i in {25..26}
do
  let var1=$i;
  echo 'Start Job ' $i 'wait for: ' $var1 's'
  qsub -v var="$var1" lissajous_jobs.sh
done
