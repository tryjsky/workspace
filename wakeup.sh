#!/bin/bash

. $(dirname "$0")/environment

echo "Starting..."
az vm start -g $RESOURCE_GROUP -n $VM_NAME

echo -n "VM IP address: "
az network public-ip show --resource-group $RESOURCE_GROUP --name ${VM_NAME}-ip --query ipAddress -o tsv
