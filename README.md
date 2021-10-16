# workspace
Startup my workspace in Microsoft Azure.

## Usage

1. Create Key Vault

Create a Key Vault to store your personal information.
The name of the Key Vault must be unique in the world.

```bash
RG_VAULT_NAME="ContosoResourceGroup"
VAULT_NAME="ContosoKeyVault"

az group create --name ${RG_VAULT_NAME} --location japaneast
az keyvault create -n ${VAULT_NAME} -g ${RG_VAULT_NAME} -l japaneast
az keyvault secret set --vault-name ${VAULT_NAME} -n "adminUser" --value "Your VM user name"
az keyvault secret set --vault-name ${VAULT_NAME} -n "adminPass" --value "Your VM password"
az keyvault secret set --vault-name ${VAULT_NAME} -n "installUri" --value "Your application download URI"
az keyvault secret set --vault-name ${VAULT_NAME} -n "appUser" --value "Your application user name"
az keyvault secret set --vault-name ${VAULT_NAME} -n "appPass" --value "Your application password"
```

1. Fork

Fork to your repository.
Edit file `environment` and set `VAULT_NAME` to the Key Vault created above.

1. Clone

Clone to an environment that can use the Azure CLI (Cloud Shell etc.).

```
git clone https://github.com/(Your account)/workspace
```

1. Deploy

Run the script.
If Cloud Shell times out, re-execute from the script that failed.

```
cd workspace
./start.sh
```