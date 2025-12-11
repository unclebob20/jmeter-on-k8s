#!/bin/bash

args=${1}
declare -A arguments=${args}
echo
for key in "${!arguments[@]}"; do
  echo "${key}=${arguments[${key}]}" >> Resources/jmeter-k8s-starterkit/scenario/${arguments[JMX_SCENARIO]}/.env
done
