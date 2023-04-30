#!/bin/bash
##
## This scripts runs Tier test in the remote bastion node
##

cd ${WORKSPACE}/ocs-upi-kvm/scripts/; . ${WORKSPACE}/env_vars.sh; ./test-ocs-ci.sh --tier ${TIER_TEST} > tier${TIER_TEST}.log
sed -n '/short test summary info/, /Running tier/p' ${WORKSPACE}/ocs-upi-kvm/scripts/tier${TIER_TEST}.log | grep -v -i "Running tier" > ${WORKSPACE}/tier${TIER_TEST}-summary.txt
awk '/passed/||/failed/||/skipped/' ${WORKSPACE}/tier${TIER_TEST}-summary.txt | grep "^=" | sed 's/= *//g' | head -1 > ${WORKSPACE}/slacksummary.txt
