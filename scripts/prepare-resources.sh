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
  MASTER_HOST=$(grep "^MASTER_HOST=" "$dependent_file" | cut -d'=' -f2-)

  sed -i "s/@[^:/]*:/@${MASTER_HOST}:/" $value_file
elif [ "$resource" = "flink" ]; then
  
  HOST=$(grep "^HOST=" "$dependent_file" | cut -d'=' -f2-)
  API_PORT=$(grep "^API_PORT=" "$dependent_file" | cut -d'=' -f2-)
  ROOT_USER=$(grep "^ROOT_USER=" "$dependent_file" | cut -d'=' -f2-)
  ROOT_PASSWORD=$(grep "^ROOT_PASSWORD=" "$dependent_file" | cut -d'=' -f2-)
#   echo "Flint depends on MinIO: HOST=$HOST, API_PORT=$API_PORT, ROOT_USER=$ROOT_USER $value_file" 

  sed -i "/name: FLINK_CFG_S3_ENDPOINT/{n;s|value:.*|value: http://${HOST}:${API_PORT}|}" $value_file
  sed -i "/name: FLINK_CFG_S3_ACCESS__KEY/{n;s|value:.*|value: ${ROOT_USER}|}" $value_file
  sed -i "/name: FLINK_CFG_S3_SECRET__KEY/{n;s|value:.*|value: ${ROOT_PASSWORD}|}" $value_file

elif [ "$resource" = "fluentbit" ]; then
  OPENSEARCH_DOMAIN=$(grep "^OPENSEARCH_DOMAIN=" "$dependent_file" | cut -d'=' -f2-)
  OPENSEARCH_PASSWORD=$(grep "^OPENSEARCH_PASSWORD=" "$dependent_file" | cut -d'=' -f2-)

  sed -i "/^[[:space:]]*Host[[:space:]]\+.*opensearch.*/s|Host[[:space:]]\+.*|Host ${OPENSEARCH_DOMAIN}|g" $value_file
  sed -i "/^[[:space:]]*HTTP_Passwd[[:space:]]\+.*/s|HTTP_Passwd[[:space:]]\+.*|HTTP_Passwd ${OPENSEARCH_PASSWORD}|g" $value_file
fi
