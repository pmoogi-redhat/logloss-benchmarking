#! /bin/bash

## fluentd collected logs and debug statements are directed to 
## sudo fluentd -c fluent-test-rotation.conf > debug-log-rotation-maxsize-128000-duration-20.txt  for each maxsize parameter value
logfileDiR=$1
debugfilename=$2
echo "no of times TailWatcher on_notify was called on the event of log file change"
grep "TailWatcher on_notify" ${debugfilename}  | wc
echo "no of actual loglines written in log file and its rotated files"
cat ${logfileDiR}/py_test.log* | wc
echo "no of loglines collected by fluentd"
grep "xxxx*" ${debugfilename}  | wc



