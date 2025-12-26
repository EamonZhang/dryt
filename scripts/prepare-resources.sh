#!/bin/bash
value_file=$1/values.yml
resource=$1
dependent=$4
name=$2
app=$3

if [ "$dependent" = "" ]; then
   exit 0
fi
# Here you can add commands to prepare resources using the provided values file
echo "Preparing resources using values file: $value_file"

dependent_file=describe/$app-${dependent}.txt

if [ ! -f "$value_file" ]; then
   echo "Not found values file: $value_file"
   exit 1
fi
# grafana depends on postgresql
if [ "$resource" = "grafana" ]; then
    source "$dependent_file"
    sed -i "s/@[^:/]*:/@${MASTER_HOST}:/" $value_file
fi