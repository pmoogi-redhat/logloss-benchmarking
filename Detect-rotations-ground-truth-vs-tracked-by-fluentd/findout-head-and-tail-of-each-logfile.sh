#! /bin/bash

debugDiR=$1
debugfile=$2

function pause(){
   read -p "$*"
}


echo all heads
pause
tmp=`head -1 ${debugDiR}/py_test.log.* | awk '{split($0,a,":") ; print a[4] }'`
for headseq in $tmp; do
echo head msgline seqno $headseq
echo grep "xxx:$headseq\"}"  $debugfile
grep "xxx:$headseq\\\"}"  $debugfile
sleep 2
done
echo all tails
pause
tmp=`tail -n 1  ${debugDiR}/py_test.log.* | awk '{split($0,a,":") ; print a[4] }'`
echo find if all tail log lines picked by fluentd
for tailseq in $tmp; do
echo grep "xxx:$tailseq\"}" $debugfile
grep "xxx:$tailseq\\\"}" $debugfile
sleep 2
done
