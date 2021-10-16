#!/bin/bash

. $(dirname "$0")/environment

ADMIN_USER=$(az keyvault secret show --vault-name ${VAULT_NAME} -n "adminUser" --query value -o tsv)
ADMIN_PASS=$(az keyvault secret show --vault-name ${VAULT_NAME} -n "adminPass" --query value -o tsv)

echo "Create a resource group..."
az group create --name $RESOURCE_GROUP --location japaneast

echo "Create a virtual machine..."
az deployment group create -g $RESOURCE_GROUP -n 'VirutualMachineDeployment'$(date +"%Y%m%d%H%M%S") \
--template-file template.json --parameters '@parameters.json' --parameters networkInterfaceName=${VM_NAME}737 \
networkSecurityGroupName=${VM_NAME}-nsg virtualNetworkName=${RESOURCE_GROUP}-vnet publicIpAddressName=${VM_NAME}-ip \
virtualMachineName=${VM_NAME} virtualMachineComputerName=${VM_NAME} virtualMachineRG=${RESOURCE_GROUP} \
adminUsername=${ADMIN_USER} adminPassword=${ADMIN_PASS}

echo "Update system settings..."
az vm run-command invoke  --command-id RunPowerShellScript -n $VM_NAME -g $RESOURCE_GROUP \
--scripts '$pagefileset = Get-WmiObject Win32_pagefilesetting' \
'$pagefileset.InitialSize = 512' \
'$pagefileset.MaximumSize = 2048' \
'$pagefileset.Put() | Out-Null' \
'Set-WinSystemLocale -SystemLocale ja-JP' \
'Set-TimeZone -Id "Tokyo Standard Time"' \
'Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\00000411" -Name "Layout File" -Value kbd106.dll'

echo "Restart..."
az vm restart -g $RESOURCE_GROUP -n $VM_NAME

. $(dirname "$0")/1-set.sh