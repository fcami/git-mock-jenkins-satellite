#!/bin/bash

if [ -z $1 ];
then
    echo "ERROR: no parameter specified. What's your build name?"
    exit 1
fi

PROJECTNAME=$1
RPMNAME=$(echo $(basename ${PROJECTNAME}) | awk -F "Z" '{print $1}')
ENVIRONMENT=$(echo ${PROJECTNAME} | awk -F "Z" '{print $2}')
JENKINSWORKSPACE=${WORKSPACE}
RPMSPEC=${JENKINSWORKSPACE}/${RPMNAME}.spec
MOCKWORKSPACE=/var/lib/mock/${ENVIRONMENT}
PMPWD=YOUR_GPG_PASS

echo Signing ${RPMNAME} in ${ENVIRONMENT} at ${JENKINSWORKSPACE}

RPMFILES="${JENKINSWORKSPACE}/output/SRPMS/* ${JENKINSWORKSPACE}/output/RPMS/*"
echo ${RPMFILES}
for rpm in ${RPMFILES} ; do /usr/libexec/jenkins-rpm-builder/expect-rpmsign.sh ${PMPWD} ${rpm} ; done


