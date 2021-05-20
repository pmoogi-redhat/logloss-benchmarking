# simulating log generation 
You can run the below script. It uses <max-log-file-size in bytes> <gap between two consecutive log line in sec> <duration of run in sec> <logfile path> <no of max backupfiles> as command line argument

 $./log-rotation-with-maxsize-experiments.sh 1024000 0.0001 100 LOGFILES/py_test.log 1000
 
You can run the below script. It uses <periodicity at which file get rotated> <gap between two consecutive log line in sec> <duration of run in sec> <logfile path> <no of max backupfiles> as command line argument

 $./log-rotation-with-periodicity-experiments.sh 1024000 0.0001 100 LOGFILES/py_test.log 1000

The above allows you to generate log lines at different rates. Payload is fixed to 1024 bytes. You can change that too.

# logloss-benchmarking
This repo used to experience and simulate log loss scenarios using Fluentd

The repo contains simulation script for 
 1. replicating log-loss at different rate of logs generation (msg line per sec or no of bytes per sec)
 2. measuring log-loss at a given setting of log-size-max limits
 
 > Note: The loader and verify-loader scripts are taken from https://github.com/ViaQ/logging-load-driver
 They are further changed to have more debug/print statements for better understanding on log-loss.

## Scenario 1:  logloss-benchmarking using loader and verify-loader programs as standalone setup

 
 > Note: Simulation script can use custom conmon binary which is changed to log in extra metadata on log-rotation event and timestamps
 >
 > ```${LOCALBIN}/podman run --log-level debug --conmon $conmonlatestlib --env MSGPERSEC --env PAYLOAD_GEN --env PAYLOAD_SIZE --env DISTRIBUTION --env STDDEV --env OUTPUT  --env REPORT --env REPORT_INTERVAL --env TOTAL_SIZE --log-opt max-size=$MAXSIZE  $imageid"``` 
 

 Below Results are obtained when setting:  
 
   `MSGPERSEC = 100`  
   `log-lines per sec = 10000`  
   `pay-load size = 1024 bytes`    
   `payload_gen method as fixed (not random)`   
   `etc.`  
 

 You can replicate these results by running the below scripts:
 

 `simulation-with-diff-config-variables.sh <MSGPERSEC> <MAXSIZE> <TOTALDURATION_OF_RUN>`
 
 e.g. simulation-with-diff-config-variables.sh 1000 1024000 10 

   $simulation-with-diff-config-variables.sh MSGPERSEC MAXSIZE TOTALDURATION_OF_RUN
 
   example as shown below
 
   $simulation-with-diff-config-variables.sh 1000 1024000 10 

 
 > [The Above generates 1000 loglines per sec of payload 1024 bytes, maxsize of logfile being 1024000 bytes, REPORT INTERVAL being set to 10 sec by loader program]

|msq-lines-per-sec log generation rate | Rate of writing to disk bytes per sec | Log-max-size limit set to.. | Loss rate(mb per sec) as we see.. |msg-len set to |
|--|--|--|--|--|
|100  | 100*1024=0.1mb| 1mb | 0.012| 1024 |
|--|--|--|--|--|
|1000 | 1000*1024=1mb | 1mb | 0.13 | 1024 |
|--|--|--|--|--|
|2000 | 2000*1024=2mb | 1mb | 0.24 | 1024 |
|--|--|--|--|--|
|3000 | 3000*1024=3mb | 1mb | 0.37 | 1024 |
|--|--|--|--|--|
|4000 | 4000*1024=4mb | 1mb | 0.50 | 1024 |
|--|--|--|--|--|
|5000 | 5000*1024=5mb | 1mb | 0.64 | 1024 |
|--|--|--|--|--|
|6000 | 6000*1024=6mb | 1mb | 0.75 | 1024 |
|--|--|--|--|--|
|7000 | 7000*1024=7mb | 1mb | 0.9  | 1024 |
|--|--|--|--|--|
|8000 | 8000*1024=8mb | 1mb | 1.04 | 1024 |
|--|--|--|--|--|
|9000 |9000*1024=9mb  | 1mb | 1.27 | 1024 |
|--|--|--|--|--|
|10000|10000*1024=10mb|1mb  | 1.3  | 1024 |
|--|--|--|--|--|


## Scenario 2 logloss-benchmarking using loader and fluentd being the log collector
Steps to simulate this scenario:


   1. Install locally fluentd by following [installing-fluentd-readme.md](installing-fluentd-readme.md)
   2. Deploy logging-load-driver docker image  
      `cd logging-load-driver`    
      `make all`  
      `cd ..`  
   3. Start the logging load driver container using run-container-for-logging-load-driver-program.sh   
      `./run-container-for-logging-load-driver-program.sh <MSEPERSEC> <MAXSIZELOGFILE> <REPORT_INTERVAL>`
             
      > e.g `./run-container-for-logging-load-driver-program.sh 100 1000 60`     
   3. Execute fluentd (in different shell)  
      `sudo chmod a=rwx /var/lib/docker/containers`    
      `sudo fluentd -c fluent-test-tail.conf`  
      
      > Note: Need to run fluentd with sudo permission, so will be able to tail root level docker directories     
      
   1. Install locally fluentd by following README.md
   
   
   2. Run the container for logging load driver program by using run-container-for-logging-load-driver-program.sh 
   
      $run-container-for-logging-load-driver-program.sh <MSEPERSEC> <MAXSIZELOGFILE> <REPORT_INTERVAL>
   
   3. run fluentd on local host as the below 
  
  Log lines generated by loader program in the step 1 gets collected by fluentd which is given fluent-test-tail.conf. The fluent-test-tail.conf must have the right path, position, and other configuration parameters specified.
  please check the content of fluent-test-tail.conf for configuring input and output plugins for fluentd
  

## Scenario 3 Analysis of how many rotations fluentd is able to track or detect vs. ground truth on actual rotations
 
 For the above analysis, python logging driver program is used as it allows you to keep backup on rotated log files. You can set a relatively a higher back on rotated files so that rotations don't roll over a given set of backup files. There are two set of logging driver programs 
  1. Periodicity based rotations e.g. one rotation per on sec, one rotation per two sec etc..
  2. Maxsize limit set on the logfiles size, when exceeds log-rotation happens
  
 For running these simulations follow the below steps
 $./log-rotation-with-maxsize-experiments.sh <maxsizeoflogfiles> <duration-between-two-log-lines> <duration-of-run> <test-log-file-name>
 e.g.
 $./log-rotation-with-maxsize-experiments.sh 10240000 0.0001 50 py_test.2.log
 or
 $./log-rotation-with-periodicity-experiments.sh <time-to-rotate> <duration-between-two-log-lines> <duration-of-run> <test-log-file-name>
 e.g.
 $./log-rotation-with-periodicity-experiments.sh 1 0.0001 10 py_test.log
 
 The above steps must be run post you start a fluentd instance by running the below. Do direct output from fluentd to a debug file.
 $sudo fluentd -c -v fluent-test-rotation.conf  >   <fluentd-debug.txt>
 
 Here .conf file points to absolute paths of log files those are generated by the logging driver program
 
 To compute the overall logloss - which loglines got missed out from fluentd collecting process run the below
 
 $./compute-loss-as-missed-loglines-and-missed-on_notify-state-call.sh <dir-where-logfiles-generated> <fluentd-debug.txt> 
 
 To know which logfiles missed out from fluentd collection run the below
 
 $ ./findout-head-and-tail-of-each-logfile.sh <dir-where-logfiles-generated> <fluentd-debug.txt> 
 
  
