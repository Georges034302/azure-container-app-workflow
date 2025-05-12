#!/bin/bash

set -e

RESOURCE_GROUP="my-rg"
ACR_NAME="myacr$RANDOM" # Use the same logic as setup.sh if needed
APP_NAME="nodejs-app"
ENV_NAME="my-container-env"

echo "🧹 Deleting Container App..."
az containerapp delete --name $APP_NAME --resource-group $RESOURCE_GROUP --yes || true

echo "🧹 Deleting Container Apps Environment..."
az containerapp env delete --name $ENV_NAME --resource-group $RESOURCE_GROUP --yes || true

echo "🧹 Deleting Azure Container Registry..."
az acr delete --name $ACR_NAME --resource-group $RESOURCE_GROUP --yes || true

echo "🧹 Deleting Resource Group (this deletes all resources above)..."
az group delete --name $RESOURCE_GROUP --yes --no-wait || true

echo "🧹 Deleting Service Principal (if exists)..."
az ad sp delete --id http://gha-deployer || true

echo "🧹 Cleanup complete."