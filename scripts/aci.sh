
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
  rm -rf ./out
  mkdir ./out
  for loc in "${locations[@]}"
  do
    cat ./template.yaml | 
    sed 's|\$name\$|'$loc'-wt|' | 
    sed 's|\$request_url\$|'$request_url'|' | 
    sed 's|\$location\$|'$loc'|' | 
    sed 's|\$mongo_url\$|'$mongo_url'|' | 
    sed 's|\$location\$|'$loc'|' > "./out/$loc-wt.yaml"

    status=$(az container show -n $loc-wt --resource-group $resource_group --query containers[0].instanceView.currentState.state 2>/dev/null)
    if [ $? -eq 0 ]
    then
      az container start -g $resource_group --name "$loc-wt" &
      echo "$loc-wt has started..."
    else
      az container create -g $resource_group --location $loc --file "./out/$loc-wt.yaml" --no-wait
      echo "$loc-wt has been created..."
    fi
  done
fi

if [ $1 == "clean" ]
then
  az group delete --name $resource_group --yes
fi
