#! /bin/bash

interval=$1
rateofmsglineG=$2
duration=$3
filelN=$4
backupFiles=$5
script=file-rotate-test-basedon-periodicity-in-time.py 
dirN=time-based-rotation-${interval}-per-sec-with-${rateofmsglineG}-msglinesinterval-duration-of-run-${duration}
filepN=pos_py

#clean up earlier run leftover log and pos files generated by logging driver program below and also pos file created by fluentd
rm -f ${filelN}* 

#run the logging drive program which does rotation of a log file based on periodicity or interval set, it also takes no of backfiles as input, i have setup it to 100 as i don't want to see any rollover happening during log rotation. This will allow me to see how many real log rotations happened in a given duration of run
python $script $interval $rateofmsglineG $filelN $backupFiles & sleep $duration ; kill $!
mkdir -p $dirN

#moving log files generated from previous step to a designated directory for future reference and any further result analysis
if test -f "$filepN"; then
    mv pos_py* $dirN/.
else
    echo "$filepN Not exists."
fi

if test -f "$filelN"; then
    mv ${filelN}*  $dirN/.
else
    echo "$filelN Not exists."
fi
