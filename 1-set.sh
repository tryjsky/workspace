#!/bin/bash

echo "[1-set]"

. $(dirname "$0")/environment

#CLIENT_IP_ADDRESS=$(wget -q -O- https://checkip.amazonaws.com/)
read -p "Your client IP address: " CLIENT_IP_ADDRESS
INSTALL_URI=$(az keyvault secret show --vault-name ${VAULT_NAME} -n "installUri" --query value -o tsv)
INSTALL_FILE="D:/"$(basename $INSTALL_URI)

echo "Update user settings..."
az vm run-command invoke  --command-id RunPowerShellScript -n $VM_NAME -g $RESOURCE_GROUP \
--scripts '@("start /wait /b powershell.exe ""Set-WinUserLanguageList -LanguageList ja-JP,en-US -Force; Set-Culture -CultureInfo ja-JP; Set-WinHomeLocation -GeoId 0x7a""", "del ""%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Startup\00setenv.lnk""", "D:\MyVPNInst.EXE") -Join "`n" | Out-File -FilePath D:/00setenv.cmd -Encoding ASCII' \
'$WsShell = New-Object -ComObject WScript.Shell' \
'$Shortcut = $WsShell.CreateShortcut("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\00setenv.lnk")' \
'$Shortcut.TargetPath = "D:\00setenv.cmd"' \
'$Shortcut.Save()' \
'Invoke-WebRequest "'${INSTALL_URI}'" -OutFile "'${INSTALL_FILE}'"'

echo "Add a NSG rule..."
az network nsg rule create -g $RESOURCE_GROUP --nsg-name ${VM_NAME}-nsg -n Port_3389 --priority 100 \
--source-address-prefixes $CLIENT_IP_ADDRESS --destination-port-ranges 3389 --access Allow --protocol Tcp

. $(dirname "$0")/2-show.sh
