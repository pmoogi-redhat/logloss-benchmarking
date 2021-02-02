#### logloss-benchmarking using loader and verify-loader programs as standalone setup

This repo contains simulation script for 
 1. replicating log-loss at different rate of logs generation (msg line per sec or no of bytes per sec)
 2. measuring log-loss at a given setting of log-size-max limits
 
 The loader and verifiy-loader scripts are taken from https://github.com/ViaQ/logging-load-driver
 They are further changed to have more debug/print statements for better understanding on log-loss.
 
 Simulation script can use a custom conmon binary which is changed to log in extra meta data on log-rotation event and timestamps
 ${LOCALBIN}/podman run --log-level debug --conmon $conmonlatestlib --env MSGPERSEC --env PAYLOAD_GEN --env PAYLOAD_SIZE --env DISTRIBUTION --env STDDEV --env OUTPUT  --env REPORT --env REPORT_INTERVAL --env TOTAL_SIZE --log-opt max-size=$MAXSIZE  $imageid" 
 
 
 
 Below Results are obtained on setting of MSGPERSEC=100 to 10000 log-lines per sec, pay-load size 1024 bytes, payload_gen method as fixed (not random) etc.
 You can replicate these results by running the below scripts :
 
 simulation-with-diff-config-variables.sh <MSGPERSEC> <MAXSIZE> <TOTALDURATION_OF_RUN>
 e.g. simulation-with-diff-config-variables.sh 1000 1024000 10 
 
 [The Above generates 1000 loglines per sec of payload 1024 bytes, maxsize of logfile being 1024000 bytes, REPORT INTERVAL being set to 10 sec by loader program]
 

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


#### logloss-benchmarking using loader and fluentd being the log collector
Steps to simulate this scenario is the below.
1. Run the container for logging load driver program by using run-container-for-logging-load-driver-program.sh 
run-container-for-logging-load-driver-program.sh <MSEPERSEC> <MAXSIZELOGFILE> <REPORT_INTERVAL>
2. run fluentd on local host as the below
 sudo fluentd -c fluent-test-tail.conf

fluent-test-tail.conf is having the below configuration 


*# Have a source directive for each log file source file.
*<source>
*    # Fluentd input tail plugin, will start reading from the tail of the log
*@type tail
*    # Specify the log file path. This supports wild card character
*path /var/lib/docker/containers/*/*json*.log
*# This is recommended – Fluentd will record the position it last read into this file. Change this folder according to your server
*pos_file PATH /home/pmoogi/docker-containerid.log.pos
*# tag is used to correlate the directives. For example, source with corresponding filter and match directives.
*tag mytagloadlogs
*format /(?<message>.*)/
*#reads the  fields from the log file in the specified format
*</source>

*<source>
* @type prometheus
*</source>

*<source>
*  @type prometheus_output_monitor
*</source>

<source>
  @type prometheus_monitor
</source>

<source>
  @type prometheus_tail_monitor
</source>

<match **>
  @type stdout
</match>
