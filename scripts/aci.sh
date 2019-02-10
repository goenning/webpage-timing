# Before executing this script, make sure you login with `az login`
# If you have multiple subscriptions under your account, select one with `az account set --subscription "<YOUR_SUBSCRIPTION NAME>"`

resource_group="webtiming-rg"
locations=( "westus" "eastus" "westeurope" "westus2" "northeurope" "southeastasia" "eastus2" "centralus" "australiaeast" "uksouth" "southcentralus" "centralindia" "southindia" "northcentralus" "eastasia" "canadacentral" "japaneast" )
request_url="https://github.com/docker"
mongo_url=""

if [ $1 == "init" ]
then
  az group create --name $resource_group --location eastus
fi

if [ $1 == "run" ]
then
  for loc in "${locations[@]}"
  do
    status=$(az container show -n $loc-wt --resource-group webtiming-rg --query containers[0].instanceView.currentState.state 2>/dev/null)
    if [ $? -eq 0 ]
    then
      az container start -g $resource_group --name "$loc-wt" &
      echo "$loc has started..."
    else
      az container create -g $resource_group --name "$loc-wt" --image goenning/webpage-timing --cpu 1 --memory 1 --location $loc --restart-policy Never --no-wait --ip-address Private --environment-variables ORIGIN=$loc REQUEST_URL=$request_url --secure-environment-variables MONGO_URL=$mongo_url
      echo "$loc has been created..."
    fi
  done
fi

if [ $1 == "clean" ]
then
  az group delete --name $resource_group --yes
fi