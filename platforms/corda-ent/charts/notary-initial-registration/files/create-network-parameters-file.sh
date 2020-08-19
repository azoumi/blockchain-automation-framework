#!/bin/sh
{{ if eq .Values.bashDebug true }}
set -x
pwd
cat -n etc/notary.conf
{{ end }}

d=$(date -d '+1 hour' --iso-8601=seconds)

export updateDate="${d%??????}.000Z"

FILE=additional-node-infos/network-parameters-initial.conf
if [[ -f "$FILE" ]]; then
    echo "$FILE exists."
fi

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
EOF

mv additional-node-infos/network-parameters-initial.conf.tmp additional-node-infos/network-parameters-initial.conf
cat additional-node-infos/network-parameters-initial.conf
echo
