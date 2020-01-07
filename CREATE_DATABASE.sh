#!/bin/bash
rnd=$RANDOM
groupName=tailwind-products-manager
accountName=tailwind-traders-$RANDOM
databaseName=tailwind
containerName=products

echo "This is your concierge tenant id. Please copy this to the clipboard and press the [Enter] key to continue."
az account list --query "[?name=='Concierge Subscription'].tenantId" -o tsv

read -p  ""

echo "Beginning database creation process..."

groupName=$(az group list --query "[0].name" -o tsv)

echo "Creating Cosmos DB database $accountName in Resource Group $groupName..."
echo "This can take up to 10 minutes. That's the perfect amount of time to watch this YouTube video: https://youtu.be/OzKk4Wfnz1k"
az cosmosdb create -n $accountName -g $groupName -o none

echo "Creating 'tailwind' database in $accountName..."
az cosmosdb sql database create -n $accountName -g $groupName --db-name tailwind -o none

echo "Creating 'products' collection in 'tailwind' database..."
az cosmosdb sql container create -g $groupName -n $accountName -c $containerName -d $databaseName -o none

echo "Finished scaffolding database"

endpoint=https://$accountName.documents.azure.com:443
key=$(az cosmosdb list-keys -g $groupName -n $accountName --query "primaryMasterKey" -o json)

echo "Installing Node modules..."

npm i --silent

echo "Populating database..."
node ./POPULATE_DATABASE.js --endpoint $endpoint --key $key --databaseName $databaseName --containerName $containerName

echo "Finished! Your database, $accountName, is now ready."
