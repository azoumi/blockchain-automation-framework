#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
{{ end }}

echo "Waiting for notary-nodeinfo/network-parameters-initial.conf ..."
echo "========================================"
ls {{ .Values.configPath }}
echo {{ .Values.configPath }}
cat /opt/corda/etc/network-parameters-initial-set-succesfully
echo "========================================"
if [ ! -f /opt/corda/etc/network-parameters-initial-set-succesfully ]
then
    until [ -f notary-nodeinfo/network-parameters-initial.conf ]
    do
        sleep 1
    done
fi

echo "Waiting for notary-nodeinfo/network-parameters-initial.conf ... done."
ls -al notary-nodeinfo/network-parameters-initial.conf
cp notary-nodeinfo/network-parameters-initial.conf {{ .Values.configPath }}/
cat {{ .Values.configPath }}/network-parameters-initial.conf


echo "Setting initial network parameters ..."
java -jar {{ .Values.jarPath }}/networkmap.jar \
	-f {{ .Values.configPath }}/nmap.conf \
	--set-network-parameters {{ .Values.configPath }}/network-parameters-initial.conf \
	--network-truststore DATA/trust-stores/network-root-truststore.jks \
	--truststore-password password \
	--root-alias cordarootca

EXIT_CODE=${?}

if [ "${EXIT_CODE}" -ne "0" ]
then
    HOW_LONG={{ .Values.sleepTimeAfterError }}
    echo
    echo "Network Map: setting network parameters failed - exit code: ${EXIT_CODE} (error)"
    echo
    echo "Going to sleep for requested ${HOW_LONG} seconds to let you login and investigate."
    echo
else
    HOW_LONG=0 
    # {{ .Values.sleepTime }} needs to be filled in
    echo
    echo "Network Map: initial network parameters have been set."
    echo "No errors."
    echo "Sleeping for requested ${HOW_LONG} seconds before disappearing."
    echo
    # touch {{ .Values.configPath }}/network-parameters-initial-set-succesfully
    echo "Writing something to file"
    echo 'content in here' > {{ .Values.configPath }}/network-parameters-initial-set-succesfully
    ls {{ .Values.configPath }}
    cat {{ .Values.configPath }}/network-parameters-initial-set-succesfully
    realpath {{ .Values.configPath }}/network-parameters-initial-set-succesfully
    echo "Done writing something to file"
    echo "# This is a file with _example_ content needed for updating network parameters" > {{ .Values.configPath }}/network-parameters-update-example.conf
    cat {{ .Values.configPath }}/network-parameters-initial.conf >> {{ .Values.configPath }}/network-parameters-update-example.conf
cat << EOF >> {{ .Values.configPath }}/network-parameters-update-example.conf
# updateDeadline=\$(date -u +'%Y-%m-%dT%H:%M:%S.%3NZ' -d "+10 minute")
parametersUpdate {
    description = "Update network parameters settings"
    updateDeadline = "[updateDeadline]"
}
EOF

fi

sleep ${HOW_LONG}
exit ${EXIT_CODE}
