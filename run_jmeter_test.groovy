assert args.backendType: "[runJmeterScenario] backendType argument must be set!"
assert args.aquaBeData: "[runJmeterScenario] aquaBeData argument must be set!"

def argsString = "("
if (args.backendType == "saas") {
    argsString = "${argsString} [AQUA_IP]=${args.aquaBeData.saas_signin_addr}"
} else if (args.backendType == "on-prem") {
    argsString = "${argsString} [AQUA_IP]=${args.aquaBeData.aquaAddr}"
} else if (args.aquaBeData == null) {
    assert args.springMusicUrl: "[runJmeterScenario] springMusicUrl argument must be set!"
    argsString = "${argsString} [SPRING_APP_URL]=${args.springMusicUrl}"
}

assert args.jmxScenario: "[runJmeterScenario] jmxScenario argument must be set!"
assert args.testDuration: "[runJmeterScenario] testDuration argument must be set!"
assert args.jmeterTestName: "[runJmeterScenario] jmeterTestName argument must be set!"
assert args.jmeterClusterName: "[runJmeterScenario] jmeterClusterName argument must be set!"
assert args.selectedTransactions: "[runJmeterScenario] selectedTransactions argument must be set!"
def jmxScenarioName = args.jmxScenario.split("\\.")[0]
def threads = args.threads == '' ? 'null' : args.threads
def tpm = args.tpm == '' ? 'null' : args.tpm
def ack_scope = args.ack_scope == '' ? 'image' : args.ack_scope
def execute_unack = args.execute_unack == '' ? 'false' : args.execute_unack
argsString = "${argsString} [BE_TYPE]=${args.backendType} [USER]=${args.aquaBeData.aquaAdminUser} [PASSWORD]=${args.aquaBeData.aquaAdminPassword} [AQUA_PORT]=${args.aquaBeData.aquaPort} [DURATION]=${args.testDuration} [JMX_SCENARIO]=${jmxScenarioName} [TEST_SELECTED_TRANSACTIONS]=${args.selectedTransactions} [THREADS]=${threads} [TPM]=${tpm} [ACK_SCOPE]=${ack_scope} [EXECUTE_UNACK]=${execute_unack} )"

jmxScenarioName = args.jmxScenario.split("\\.")[0]
mkdir -p jmeter-k8s-starterkit/scenario/${jmxScenarioName}
sh script: "chmod +x jmeter/create_run_vars_file.sh"
sh script: "jmeter/create_run_vars_file.sh \"${argsString}\""

sh script: "cp jmeter/scenarios/${args.jmxScenario} jmeter-k8s-starterkit/scenario/${jmxScenarioName}/"
sh script: "chmod +x jmeter-k8s-starterkit/*.sh"

sh script: "jmeter-k8s-starterkit/start_test.sh -j ${args.jmxScenario} -n jmeter -c -m -i 1 -r ${args.jmeterTestName} -e ${args.jmeterClusterName}"
sh script: "jmeter-k8s-starterkit/save_report.sh ${args.jmeterTestName} ${args.jmeterClusterName}"
saveFileToAwsS3 fileName: "report-${args.jmeterTestName}.zip",
                pathToSave: "test-results/jmeter-console-api/report-${args.jmeterTestName}.zip"
