#!/bin/bash
##
## This script runs Performance test in the remote bastion node
##
#create cephtools pod
 oc patch storagecluster ocs-storagecluster -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
scp -r -i ${WORKSPACE}/deploy/id_rsa -o 'StrictHostKeyChecking=no' root@${BASTION_IP}:/root/openstack-upi/auth/ ${WORKSPACE}/
cp /usr/bin/oc ${WORKSPACE}/ocs-upi-kvm/src/ocs-ci/bin/
mkdir ${WORKSPACE}/bin; cp /usr/bin/oc ${WORKSPACE}/bin/;
# Change to the correct directory once
cd ${WORKSPACE}/ocs-upi-kvm/scripts/ || { echo "Error: Directory not found"; exit 1; }

# Source environment variables
. ${WORKSPACE}/env_vars.sh

# Loop over both test types (file and block)
for PERF_TYPE in file block; do
    # Run FIO test and log output
    ./run-fio.sh ${PERF_TYPE} > performance_${PERF_TYPE}.log 2>&1

    # Extract the last numerical value (FILE_NUM) from the log
    FILE_NUM=$(awk '/Fio results directory:/ {val=$NF} END {print val}' performance_${PERF_TYPE}.log)

    # Check if FILE_NUM is empty
    if [[ -z "$FILE_NUM" ]]; then
        echo "Error: Unable to extract FILE_NUM from performance_${PERF_TYPE}.log."
        exit 1
    fi

    # Run fio-report.sh with extracted FILE_NUM
    ./fio-report.sh ${PERF_TYPE} "$FILE_NUM" > performance-${PERF_TYPE}-report.log
done
