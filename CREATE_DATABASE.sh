#!/bin/bash
rndm=$RANDOM
name=tailwind
groupName=RG-$rndm
accountName=$name-$rndm
databaseName=tailwind
containerName=products

echo az account list --query "[?name=='Concierge Subscription'].tenantId" -o tsv
read -p  "This is your concierge tenant id. Please copy this to the clipboard and then press [Enter] key."

echo "Beginning database creation process..."

echo "Creating Resource Group: $groupName..."
az group create -n $groupName -o none

echo "Creating Cosmos DB database $accountName in Resource Group $groupName..."
echo "This can take up to 10 minutes. That's the perfect amount of time to watch this YouTube video: https://youtu.be/OzKk4Wfnz1k"
az cosmosdb create -n $accountName -g $groupName -o none

echo "Creating 'tailwind' database in $accountName..."
az cosmosdb database create -n $accountName -g $groupName --db-name tailwind -o none

echo "Creating 'products' collection in 'tailwind' database..."
az cosmosdb collection create -g $groupName -n $accountName -c $containerName -d $databaseName -o none

echo "Finished scaffolding database"

endpoint=https://$accountName.documents.azure.com:443
key=$(az cosmosdb list-keys -g $groupName -n $accountName --query "primaryMasterKey" -o json)

echo "Installing Node modules..."

npm i --silent

echo "Populating database..."
node data/POPULATE_DATABASE.js --endpoint $endpoint --key $key --databaseName $databaseName --containerName $containerName

echo "Finished! Your database, $accountName, is now ready."

echo "Please copy the following into the index.html page in your project per the instructions in the Learn module."