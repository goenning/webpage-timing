# Before executing this script, make sure you login with `az login`
# If you have multiple subscriptions under your account, select one with `az account set --subscription "<YOUR_SUBSCRIPTION NAME>"`

# The name of the resource group to be used on Azure
resource_group="webtiming-rg"

# The list of locations from where the test will be executed
locations=( "westus" "eastus" "westeurope" "westus2" "northeurope" "southeastasia" "eastus2" "centralus" "australiaeast" "uksouth" "southcentralus" "centralindia" "southindia" "northcentralus" "eastasia" "canadacentral" "japaneast" )

# The URL of the webpage we want to test
request_url="https://github.com/docker"

# The connection string to a MongoDB instance
mongo_url=""

if [ $1 == "init" ]
then
  az group create --name $resource_group --location eastus
fi

if [ $1 == "run" ]
then
  for loc in "${locations[@]}"
  do
    for i in {1..20}
    do
      status=$(az container show -n $loc-wt-$i --resource-group webtiming-rg --query containers[0].instanceView.currentState.state 2>/dev/null)
      if [ $? -eq 0 ]
      then
        az container start -g $resource_group --name "$loc-wt-$i" &
        echo "$loc-wt-$i has started..."
      else
        az container create -g $resource_group --name "$loc-wt-$i" --image goenning/webpage-timing --cpu 1 --memory 1 --location $loc --restart-policy Never --no-wait --ip-address Private --environment-variables ORIGIN=$loc REQUEST_URL=$request_url --secure-environment-variables MONGO_URL=$mongo_url
        echo "$loc-wt-$i has been created..."
      fi
    done
  done
fi

if [ $1 == "clean" ]
then
  az group delete --name $resource_group --yes
fi