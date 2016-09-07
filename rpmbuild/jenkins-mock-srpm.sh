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

echo Building ${RPMNAME} in ${ENVIRONMENT} at ${JENKINSWORKSPACE} via ${MOCKWORKSPACE}

/usr/bin/mock --buildsrpm -r ${ENVIRONMENT} --spec ${JENKINSWORKSPACE}/${RPMNAME}.spec  --sources ${JENKINSWORKSPACE}/sources

EXCODE=$?

mkdir -p ${JENKINSWORKSPACE}/SRPMS
rsync -avh ${MOCKWORKSPACE}/result/* ${JENKINSWORKSPACE}/SRPMS/

exit ${EXCODE}

