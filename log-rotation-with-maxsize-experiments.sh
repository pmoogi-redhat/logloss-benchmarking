#! /bin/bash

maxsize=$1
rateofmsglineG=$2
duration=$3
filelN=$4
noofbackupfiles=$5
filepN=pos_py
script=file-rotate-test-basedon-maxsize-of-logfile.py
dirN=maxsize-based-rotation-${maxsize}-per-sec-with-${rateofmsglineG}-msglinesinterval-duration-of-run-${duration}

#clean up earlier run leftover log and pos files generated by logging driver program below and also pos file created by fluentd
if test -f "${filelN}"; then
    echo "${filelN} exists."
    dirN=`dirname ${filelN}`
    echo $dirN
    rm -f  ${filelN}.*
    mkdir -p $dirN
else
    echo "${filelN} doesn't exists."
    dirN=`dirname ${filelN}`
    echo $dirN
    mkdir -p $dirN
fi 
#rm pos_py*

#run the logging drive program which does rotation of a log file based on maxsize limits, it also takes no of backfiles as input, i have setup it to 100 as i don't want to see any rollover happening during log rotation. This will allow me to see how many real log rotations happened in a given duration of run
python $script $maxsize $rateofmsglineG $filelN $noofbackupfiles  & sleep $duration ; kill $!

mkdir -p $dirN

#moving log files generated from previous step to a designated directory for future reference and any further result analysis
if test -f "$filepN"; then
    mv ${filepN}* $dirN/.
else
    echo "$filepN Not exists."
fi

if test -f "$filelN"; then
    mv ${filelN}* $dirN/.
else
    echo "$filelN Not exists."
fi
