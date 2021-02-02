#! /bin/bash
#ensure you got Docker version 20.10.2, installed

if [ $1 = "--help"  ]
then
        echo Give command line argument as :  Messagelines_per_sec Log-size-max report-interval
        echo Example: simulation-with-diff-cofig-variables.sh 100 1000000 5
        exit
fi

export LOCALBIN=/home/pmoogi/go/src/github.com/containers/podman/bin
export MSGPERSEC=$1
export MAXSIZE=$2
export REPORT_INTERVAL=$3
export READ_INTERVAL=$4

export PAYLOAD_SIZE=1024
export DISTRIBUTION=gaussian
export PAYLOAD_GEN=fixed
export STDDEV=32
export OUTPUT=stdout
export REPORT=inline
#for total size 100mb set the below value
export TOTAL_SIZE=100

export NOW=$(date +"%m%d%Y%H%M")

echo "Configuration:
-=-=-=-=-=-=-
Messagelines_per_sec=$MSGPERSEC
Max_size_log_file_limit=$MAXSIZE
Report Interval=$REPORT_INTERVAL
Payload_size bytes=$PAYLOAD_SIZE
Payload Gen Method=${PAYLOAD_GEN}
Payload std dev=${STDDEV}
Logs from container writing to data pipe type=$OUTPUT
Reporting method=$REPORT
Report Interval=$REPORT_INTERVAL
TOTAL_SIZE considered for counting log-loss =$TOTAL_SIZE
"


function pause(){
   read -p "$*"
}


#load-logs-drive image needs to be built first by following the below steps
#step 1 cd ${HOME}/<dir where you got logging-load-driver repo>/logging-load-driver
#step 2 make all

#get imageid post getting the image built
export dockerimageid=`docker images | grep latest | grep docker-logging-load-driver-image | awk '{print $3}'`


DockerCMD="docker run -v /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro -u $( id -u $USER ):$( id -g $USER ) -v /var/lib/docker/containers:/var/lib/docker/containers:ro  --log-opt max-size=$MAXSIZE  --log-opt tag="docker.{{.ID}}"  --env MSGPERSEC --env PAYLOAD_GEN --env PAYLOAD_SIZE --env DISTRIBUTION --env STDDEV --env OUTPUT --env REPORT --env REPORT_INTERVAL --env TOTAL_SIZE $dockerimageid"


echo -e "About to execute following (in docker):
-==--==-=-=-\n
${DockerCMD}\n
Press [Enter] key to execute"
pause

####
$DockerCMD
pause 'post docker cmd execution'
