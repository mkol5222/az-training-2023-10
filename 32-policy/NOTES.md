
```bash
# REMINDER - commands to enable API and add API users are run on CP VM
# this is how to access it

# add SSH config for "cp"
# terraform output -raw cp_sshconfig >> ~/.ssh/config

# check folder!!!
pushd /workspaces/az-training-2023-10/31-az-training
# password reminder 
terraform output -raw cp_pass; echo
# CP IP
terraform output -raw cp_ip; echo
# login
popd
ssh cp


# enable API access

# RUN ON CP: make sure API is ready - CP mgmt is up
while true; do
    status=`api status |grep 'API readiness test SUCCESSFUL. The server is up and ready to receive connections' |wc -l`
    echo "Checking if the API is ready"
    if [[ ! $status == 0 ]]; then
         break
    fi
       sleep 15
    done
echo "API ready " `date`

# RUN ON CP: expose API server
sleep 5
echo "Set R80 API to accept all ip addresses"
mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" --domain 'System Data'
echo "Restarting API Server"
api restart

# RUN ON CP: add api_user
mgmt_cli -r true add administrator name "api_user" password "Vpn123Vpn123#nok" must-change-password false \
    authentication-method "check point password" permissions-profile "read write all"  --domain 'System Data' --format json
mgmt_cli -r true install-database targets.1 chkp-standalone
```
### Logout from CP

```bash
# check folder!
pushd /workspaces/az-training-2023-10/32-policy
# get CP server IP
CPIP=$(pushd /workspaces/az-training-2023-10/31-az-training>/dev/null; terraform output -raw cp_ip; popd>/dev/null)
pushd /workspaces/az-training-2023-10/32-policy

# save
cat << EOF > /workspaces/az-training-2023-10/32-policy/terraform.tfvars
cp_server = "$CPIP"
EOF

# check
cat terraform.tfvars
```

```bash
# apply terraform
terraform init
terraform plan
terraform apply

# and publish
terraform apply -auto-approve -var publish=true
# install
terraform apply -auto-approve -var install=true
```

```bash
# route Linux through CP
pushd /workspaces/az-training-2023-10/31-az-training
terraform apply -auto-approve -var route_through_firewall=true
popd

# and now connect from Linux to Internet
ssh ubuntu1 'while true; do ping -c1 1.1.1.1; curl -s ip.iol.cz/ip/ -m1 ; echo; sleep 2; done'

# and now remove CP route
pushd /workspaces/az-training-2023-10/31-az-training
terraform apply -auto-approve -var route_through_firewall=false
popd

# cleanup
pushd /workspaces/az-training-2023-10/32-policy
terraform destroy
# publish in SmartConsole

# Azure cleanup
pushd /workspaces/az-training-2023-10/31-az-training
terraform destroy
```