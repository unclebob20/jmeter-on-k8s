#!/bin/bash
#-----------------------#
log()
#-----------------------#
{
  lTmp=$1
	time_trace=$(date "+%y-%m-%d %H:%M:%S")
	echo "$time_trace | ${!lTmp} ${@:2} ${reset}"
}

if [[ $(kubectl get namespace) =~ "jmeter" ]]; then
  log info "Jmeter exists"
  if [[ ! $(kubectl -n jmeter get svc) =~ "grafana" ]]; then
    log info "Grafana installation not found. Installing all tools"
    kubectl -n jmeter create -R -f Resources/jmeter-k8s-starterkit/k8s/tool/
  fi
else
  log info "Namespace jmeter not found. Full install"
  kubectl create namespace jmeter
  kubectl -n jmeter create -R -f Resources/jmeter-k8s-starterkit/k8s/
fi

log info "Jmeter and tools are installed"