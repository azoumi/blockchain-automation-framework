#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
pwd
cat -n etc/notary.conf
{{ end }}

d=$(date -d '+1 hour' --iso-8601=seconds)

export updateDate="${d%??????}.000Z"

# For now, we are using a 'hardcoded' nodeInfo filename, to avoid having to save the hash in Vault
envsubst <<"EOF" > additional-node-infos/network-parameters-initial.conf.tmp
notaries : [
  {
    notaryNodeInfoFile: "notary-nodeinfo/notary_nodeinfo"
    validating = true
  }
]
minimumPlatformVersion = 1
maxMessageSize = 10485760
maxTransactionSize = 10485760
eventHorizonDays = 1
parametersUpdate {
    description = "Test update"
    updateDeadline = "${updateDate}" # ISO-8601 time, substitute it with update deadline
}
EOF

mv additional-node-infos/network-parameters-initial.conf.tmp additional-node-infos/network-parameters-initial.conf
cat additional-node-infos/network-parameters-initial.conf
echo
