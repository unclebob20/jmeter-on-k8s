Deploy Jmeter On Gke Cluster
-----------------------------
kubectl -n jmeter create -R -f jmeter-k8s-starterkit/k8s/

Verify Jmeter Installation
--------------------------
jmeter/verify_jmeter_installation_on_cluster.sh

Run Jmeter Scenario (groovy)
-------------------
