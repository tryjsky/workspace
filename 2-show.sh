#!/bin/bash

echo "[2-show]"

. $(dirname "$0")/environment

echo -n "VM IP address: "
az network public-ip show --resource-group $RESOURCE_GROUP --name ${VM_NAME}-ip --query ipAddress -o tsv
echo -n "Application secret: "
az keyvault secret show --vault-name ${VAULT_NAME} -n "appUser" --query value -o tsv
az keyvault secret show --vault-name ${VAULT_NAME} -n "appPass" --query value -o tsv
