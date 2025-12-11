slave_array=(10.0.0.201 10.0.1.6 10.0.2.8 10.0.3.6 10.0.3.7); index=5 && while [ ${index} -gt 0 ]; do for slave in ${slave_array[@]}; do if echo 'test open port' 2>/dev/null > /dev/tcp/${slave}/1099; then echo ${slave}' ready' && slave_array=(${slave_array[@]/${slave}/}); index=$((index-1)); else echo ${slave}' not ready'; fi; done; echo 'Waiting for slave readiness'; sleep 2; done
echo "Installing needed plugins for master"
cd /opt/jmeter/apache-jmeter/bin
sh PluginsManagerCMD.sh install-for-jmx my-scenario.jmx
echo "Done installing plugins, launching test"
jmeter -Ghost=google.com -Gport=443 -Gprotocol=https -Gthreads=1 -Gduration=600 -Grampup=6 --reportatendofloadtests --reportoutputfolder /report/report-my-scenario.jmx-2024-01-03_105221 --logfile /report/my-scenario.jmx_2024-01-03_105221.jtl --nongui --testfile my-scenario.jmx -Dserver.rmi.ssl.disable=true --remoteexit --remotestart 10.0.0.201,10.0.1.6,10.0.2.8,10.0.3.6,10.0.3.7 >> jmeter-master.out 2>> jmeter-master.err &
trap 'kill -10 1' EXIT INT TERM
java -jar /opt/jmeter/apache-jmeter/lib/jolokia-java-agent.jar start JMeter >> jmeter-master.out 2>> jmeter-master.err
echo "Starting load test at : Wed Jan  3 10:52:21 UTC 2024" && wait
