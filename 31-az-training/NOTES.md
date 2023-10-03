# restricted Azure lab

Create CloudLabsAi lab and use provided credentials
to login to https://portal.azure.com 
Look at resource groups and note 2nd resource group name:
e.g. ODL-ccvsa-1112866-02
under https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups 

Now it is time for our Codespace also talk to Azure.
Login with Azure CLI:
```bash
# in VSCODE desktop
az login
# or in Codespace in browser
az login --use-device-code

# check that you are now logged in
az account list -o table
```

Terraform will use Azure CLI session to operate in Azure.
Your permissions are however limited and 
we are restricted to deploy to specific Resource Group
that can be specified in Terraform variables.
Keep route_through_firewall false as no FW exists yet.
Modify and run script below:

```bash
# configure template
cat << EOF > terraform.tfvars
rg = "ODL-ccvsa-1113692-02"
admin_password = "Vpn123456#Ok"
route_through_firewall = false
EOF

# review
cat terraform.tfvars
```

Now terraform knows what to do and we can start using it:

```bash
# prepare
terraform init

# plan
terraform plan

# deploy
terraform apply
```

This is how to access Linux VM:

```bash
# Linux SSH access
mkdir -p ~/.ssh
terraform output -raw ssh_config > ~/.ssh/config
terraform output -raw ssh_config > ~/.ssh/config
terraform output -raw ssh_key > ~/.ssh/ubuntu1.key
chmod 400 ~/.ssh/ubuntu1.key
# enjoy access
ssh ubuntu1
```

This is how to access CHKP VM:

```bash

```

# fix permissions for CP serial console


```bash

# remember to remove resources
terraform destroy
```
Consider ~/.ssh/config for CP
```bash
cat << EOF >> ~/.ssh/config
Host labcp
   HostName 20.109.190.222
   User admin
   PubkeyAuthentication no
EOF
```