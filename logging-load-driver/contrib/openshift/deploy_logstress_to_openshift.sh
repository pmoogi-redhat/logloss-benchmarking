# main
#!/bin/bash


# Selecting worker node to use
select_node_to_use() {
  echo "--> Selecting node to use" 
  export NODE_TO_USE=$(oc get nodes --selector='!node-role.kubernetes.io/master' --sort-by=".metadata.name" -o=jsonpath='{.items[0].metadata.name}')
  echo "Using node: $NODE_TO_USE" 
}

# configure containers log-max-size to 10MB
configure_workers_log_rotation() {
  echo "--> Configuring log-max-size for nodes to 10MB" 
  cat > /tmp/KubeletConfigLogRotation.yaml <<EOF 
apiVersion: machineconfiguration.openshift.io/v1
kind: KubeletConfig
metadata:
  name: cr-logrotation
spec:
  machineConfigPoolSelector:
    matchLabels:
      custom-kubelet: logrotation
  kubeletConfig:
    containerLogMaxFiles: 7
    container-log-max-size: 10Mi
EOF

  LOGROTATION_LABEL=$(oc describe machineconfigpool worker | grep logrotation)
  if [ -z "$LOGROTATION_LABEL" ]; then 
    oc label machineconfigpool worker custom-kubelet=logrotation
    oc create -f /tmp/KubeletConfigLogRotation.yaml
    oc get machineconfig | grep -i kubelet
  fi
}

# delete logstress project if it exists (to get new fresh deployment)
delete_logstress_project_if_exists() {
PROJECT_LOGSTRESS=$(oc get project | grep logstress)
if [ ! -z "$PROJECT_LOGSTRESS" ]; then 
  echo "--> Deleting logstress namespace" 
  oc delete project logstress
  while : ; do
    PROJECT_LOGSTRESS=$(oc get project | grep logstress)
    if [ -z "$PROJECT_LOGSTRESS" ]; then break; fi 
    sleep 1
  done
fi
}

# create and switch context to logstress project
create_logstress_project() {
  echo "--> Creating logstress namespace"
  oc label nodes $NODE_TO_USE logstress=true --overwrite
  oc adm new-project --node-selector='logstress=true' logstress
  oc project logstress
}

# set credentials (allow privileged) 
set_credentials() {
  oc adm policy add-scc-to-user privileged -z default
  oc adm policy add-cluster-role-to-user cluster-reader -z default
}

# deoploy logstress
deploy_logstress() {
  DEPLOY_YAML=logstress-template.yaml

  echo "--> Deploying $DEPLOY_YAML"
  oc process -f $DEPLOY_YAML | oc apply -f -
}

# deoploy logcollector (fluentd)
deploy_logcollector() {
  DEPLOY_YAML=fluentd-template.yaml

  echo "--> Deploying $DEPLOY_YAML"
  oc delete configmap fluentd-config
  oc create configmap fluentd-config --from-file=fluent.conf
  oc process -f $DEPLOY_YAML | oc apply -f -
}

# deoploy capturestatistics
deploy_capturestatistics() {
  DEPLOY_YAML=capture-statistics-template.yaml

  echo "--> Deploying $DEPLOY_YAML"
  oc process -f $DEPLOY_YAML | oc apply -f -
}

evacuate_node_for_performance_tests() {
  echo "--> Evacuating $NODE_TO_USE"
  oc get pods --all-namespaces -o wide | grep $NODE_TO_USE
  
  oc adm cordon $NODE_TO_USE
  oc adm drain $NODE_TO_USE --pod-selector='app notin (low-log-stress,heavy-log-stress,fluentd,capturestatistics)' --ignore-daemonsets=true --delete-local-data --force
}

return_node_to_normal() {
  echo "--> Allow sceduling on $NODE_TO_USE"
  oc adm uncordon $NODE_TO_USE
  while : ; do
    NODE_SCHEDULING_DISABLED=$(oc get nodes --selector='!node-role.kubernetes.io/master' | grep SchedulingDisabled)
    if [ -z "$NODE_SCHEDULING_DISABLED" ]; then break; fi 
    sleep 1
  done
  oc get nodes --selector='!node-role.kubernetes.io/master'
}


# print pod status
print_pods_status () {
  echo -e "\n"
  oc get pods
}

# print usage insturctions
print_usage_insturctions () {
  echo -e "\n\nExpore logs of relevant pods\n"
  echo -e "Expore logs of capturestatistics pod\n"
}

main() {
  select_node_to_use
  configure_workers_log_rotation
  return_node_to_normal
  delete_logstress_project_if_exists
  create_logstress_project
  set_credentials
  deploy_logstress
  deploy_logcollector
  deploy_capturestatistics
  evacuate_node_for_performance_tests
  print_pods_status
  print_usage_insturctions
}

main

