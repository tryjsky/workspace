#!/bin/bash

VAULT_NAME=kv-jp-co-nsw-ryakush1
RESOURCE_GROUP=rg-corporate-002
VM_NAME=vmremotework003

#CLIENT_IP_ADDRESS=$(wget -q -O- https://checkip.amazonaws.com/)
read -p "Your client IP address: " CLIENT_IP_ADDRESS
ADMIN_USER=$(az keyvault secret show --vault-name ${VAULT_NAME} -n "adminUser" --query value -o tsv)
ADMIN_PASS=$(az keyvault secret show --vault-name ${VAULT_NAME} -n "adminPass" --query value -o tsv)
INSTALL_URI=$(az keyvault secret show --vault-name ${VAULT_NAME} -n "installUri" --query value -o tsv)
INSTALL_FILE="D:/"$(basename $INSTALL_URI)

az group create --name $RESOURCE_GROUP --location japaneast

az deployment group create -g $RESOURCE_GROUP -n 'VirutualMachineDeployment'$(date +"%Y%m%d%H%M%S") \
--template-file template.json --parameters '@parameters.json' --parameters networkInterfaceName=${VM_NAME}737 \
networkSecurityGroupName=${VM_NAME}-nsg virtualNetworkName=${RESOURCE_GROUP}-vnet publicIpAddressName=${VM_NAME}-ip \
virtualMachineName=${VM_NAME} virtualMachineComputerName=${VM_NAME} virtualMachineRG=${RESOURCE_GROUP} \
adminUsername=${ADMIN_USER} adminPassword=${ADMIN_PASS}

az vm run-command invoke  --command-id RunPowerShellScript -n $VM_NAME -g $RESOURCE_GROUP \
--scripts '$pagefileset = Get-WmiObject Win32_pagefilesetting' \
'$pagefileset.InitialSize = 512' \
'$pagefileset.MaximumSize = 2048' \
'$pagefileset.Put() | Out-Null' \
'Set-WinSystemLocale -SystemLocale ja-JP' \
'Set-TimeZone -Id "Tokyo Standard Time"' \
'Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\00000411" -Name "Layout File" -Value kbd106.dll'

az vm restart -g $RESOURCE_GROUP -n $VM_NAME

az vm run-command invoke  --command-id RunPowerShellScript -n $VM_NAME -g $RESOURCE_GROUP \
--scripts '@("start /wait /b powershell.exe ""Set-WinUserLanguageList -LanguageList ja-JP,en-US -Force; Set-Culture -CultureInfo ja-JP; Set-WinHomeLocation -GeoId 0x7a""", "del ""%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\00setenv.lnk""", "D:\MyVPNInst.EXE") -Join "`n" | Out-File -FilePath D:/00setenv.cmd -Encoding ASCII' \
'$WsShell = New-Object -ComObject WScript.Shell' \
'$Shortcut = $WsShell.CreateShortcut("C:\Users\'${ADMIN_USER}'\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\00setenv.lnk")' \
'$Shortcut.TargetPath = "D:\00setenv.cmd"' \
'$Shortcut.Save()' \
'Invoke-WebRequest "'${INSTALL_URI}'" -OutFile "'${INSTALL_FILE}'"'

az network nsg rule create -g $RESOURCE_GROUP --nsg-name ${VM_NAME}-nsg -n Port_3389 --priority 100 \
--source-address-prefixes $CLIENT_IP_ADDRESS --destination-port-ranges 3389 --access Allow --protocol Tcp

echo -n "VM IP address: "
az network public-ip show --resource-group $RESOURCE_GROUP --name ${VM_NAME}-ip --query ipAddress -o tsv
echo -n "Application secret: "
az keyvault secret show --vault-name ${VAULT_NAME} -n "appUser" --query value -o tsv
az keyvault secret show --vault-name ${VAULT_NAME} -n "appPass" --query value -o tsv
