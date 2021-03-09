# main
#!/bin/bash

# delete logstress project if it exists (to get new frech deployment)
delete_logstress_project_if_exists() {
PROJECT_LOGSTRESS=$(oc get project | grep logstress)
if [ ! -z "$PROJECT_LOGSTRESS" ]; then 
  oc delete project logstress
  while : ; do
    PROJECT_SKYDIVE=$(oc get project | grep logstress)
    if [ -z "$PROJECT_SKYDIVE" ]; then break; fi 
    sleep 1
  done
fi
}

# create and switch context to logstress project
create_logstress_project() {
  oc adm new-project --node-selector='' logstress
  oc project logstress
}

# deoploy logstress
deploy_logstress() {
  DEPLOY_YAML=logstress-template.yaml

  echo -e "\nDeploying $DEPLOY_YAML\n"
  oc process -f $DEPLOY_YAML | oc apply -f -
}

# print pod status
print_pods_status () {
  echo -e "\n"
  oc get pods
}

# print usage insturctions
print_usage_insturctions () {
  echo -e "\n\n Expore logs on relevant pods \n\n"
}

main() {
  delete_logstress_project_if_exists
  create_logstress_project
  deploy_logstress
  print_pods_status
  print_usage_insturctions
}

main

