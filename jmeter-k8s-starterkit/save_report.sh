#!/bin/bash

report_name=${1}
cluster_name=${2}

#-----------------------#
log()
#-----------------------#
{
lTmp=$1
		time_trace=`date "+%y-%m-%d %H:%M:%S"`
		echo "$time_trace | ${!lTmp} ${@:2} ${reset}"

}

kubecmd="kubectl --kubeconfig=${cluster_name}.conf"

SECONDS=0  # Initialize timer
while [[ $(${kubecmd} -n jmeter get pods) =~ "master" ]]; do
  log info "Wait while master pod stops"

  # Break the loop if more than 5 minutes have passed
  if [[ $SECONDS -ge 300 ]]; then
    log info "Timeout reached (5 minutes), exiting loop."
    break
  fi
  sleep 10
  if [[ $(${kubecmd} -n jmeter get cronjobs jobs-cleanup -o json | jq -r '.spec.suspend') == 'true' ]]; then
    ${kubecmd} -n jmeter patch cronjobs jobs-cleanup -p '{"spec" : {"suspend" : false }}'
  fi
done

sleep 10
${kubecmd} -n jmeter patch cronjobs jobs-cleanup -p '{"spec" : {"suspend" : false }}'

log info "Start new master for copy report"
${kubecmd} -n jmeter apply -f Resources/jmeter-k8s-starterkit/k8s/jmeter/jmeter-master.yaml
sleep 10

log info "Waiting for master pod to be ready..."
if ${kubecmd} wait --for=condition=ready pod -l app=jmeter-master -n jmeter --timeout=300s; then
    temp_master_pod=$(${kubecmd} -n jmeter get pods | awk '/jmeter-master/ {print $1}')
    log info "Master pod is ready"
else
    log error "Master pod failed to become ready within timeout"
    ${kubecmd} -n jmeter describe pod -l app=jmeter-master
    exit 1
fi


log info "==== Copy Test Report to S3 ===="
${kubecmd} cp jmeter/${temp_master_pod}:/report/report-${report_name} report-${report_name}
log info "copy report-${report_name}/statistics.json to results_${report_name}.json"
cat report-${report_name}/statistics.json | jq -c > jmeter_test_results.json

zip -r -q report-${report_name}.zip report-${report_name}
${kubecmd} -n jmeter patch cronjobs jobs-cleanup -p '{"spec" : {"suspend" : false }}'
