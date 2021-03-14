#!/bin/bash

source ./deploy_functions.sh


#default parameters
stress_profile="very-light"
evacuate_node="false"
fluentd_image="quay.io/openshift/origin-logging-fluentd:latest"

show_usage() {
  echo "
usage: deploy_to_openshift [options]
  options:
    -h, --help              Show usage
    -e  --evacuate=[enum]   Evacuate node  (false, true  default: false)
    -p  --profile=[enum]    Stress profile (no-stress, very-light, light, medium, heavy  default: very-light)
    -i  --image=[string]    Fluentd image to use (default: quay.io/openshift/origin-logging-fluentd:latest)
"
  exit 0
}

for i in "$@"
do
case $i in
    -e=*|--evacuate_node=*) evacuate_node="${i#*=}"; shift ;;
    -p=*|--profile=*) stress_profile="${i#*=}"; shift ;;
    -i=*|--image=*) fluentd_image="${i#*=}"; shift ;;
    --nothing) nothing=true; shift ;;
    -h|--help|*) show_usage;;
esac
done

select_stress_profile() {
  number_heavy_stress_containers=2
  number_low_stress_containers=10
  heavy_containers_msg_per_sec=1000
  low_containers_msg_per_sec=10
  number_of_log_lines_between_reports=10;
  maximum_logfile_size=10485760;

  case $stress_profile in
      "no-stress")
        number_heavy_stress_containers=0;
        heavy_containers_msg_per_sec=0;
        number_low_stress_containers=0;
        low_containers_msg_per_sec=0;
        number_of_log_lines_between_reports=10;
        maximum_logfile_size=10485760;
        shift ;;
      "very-light")
        number_heavy_stress_containers=0;
        heavy_containers_msg_per_sec=0;
        number_low_stress_containers=1;
        low_containers_msg_per_sec=10;
        number_of_log_lines_between_reports=100;
        maximum_logfile_size=10485760;
        shift ;;
      "light")
        number_heavy_stress_containers=1;
        heavy_containers_msg_per_sec=100;
        number_low_stress_containers=2;
        low_containers_msg_per_sec=10;
        number_of_log_lines_between_reports=1000;
        maximum_logfile_size=1048576;
        shift ;;
      "medium")
        number_heavy_stress_containers=2;
        heavy_containers_msg_per_sec=1000;
        number_low_stress_containers=10;
        low_containers_msg_per_sec=10;
        number_of_log_lines_between_reports=20000;
        maximum_logfile_size=1048576;
        shift ;;
      "heavy")
        number_heavy_stress_containers=4;
        heavy_containers_msg_per_sec=100000;
        number_low_stress_containers=20;
        low_containers_msg_per_sec=10;
        number_of_log_lines_between_reports=200000;
        maximum_logfile_size=1048576;
        shift ;;
      *) show_usage;;
  esac
}

show_configuration() {

echo "
Note: get more deployment options with -h

Configuration:
-=-=-=-=-=-=-
Evacuate node --> $evacuate_node
Stress profile --> $stress_profile

number of heavy stress containers --> $number_heavy_stress_containers
Heavy stress containers msg per second --> $heavy_containers_msg_per_sec
number of low stress containers --> $number_low_stress_containers
Low stress containers msg per second --> $low_containers_msg_per_sec

Number of log lines between reports --> $number_of_log_lines_between_reports
Maximum size of log file --> $maximum_logfile_size
Fluentd image used --> $fluentd_image
"
}

main() {
  select_stress_profile
  show_configuration
  select_node_to_use
  configure_workers_log_rotation $maximum_logfile_size
  return_node_to_normal
  delete_logstress_project_if_exists
  create_logstress_project
  set_credentials
  deploy_logstress $number_heavy_stress_containers $heavy_containers_msg_per_sec $number_low_stress_containers $low_containers_msg_per_sec
  deploy_log_collector "$fluentd_image"
  deploy_capture_statistics $number_of_log_lines_between_reports

  if $evacuate_node ; then evacuate_node_for_performance_tests; fi

  print_pods_status
  print_usage_instructions
}

main

