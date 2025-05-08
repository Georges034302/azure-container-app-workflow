#!/bin/bash

set -e

RESOURCE_GROUP="my-rg"
LOCATION="australiaeast"
ACR_NAME="myacr$RANDOM"
APP_NAME="nodejs-app"
ENV_NAME="my-container-env"

echo "🔧 Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "🐳 Creating Azure Container Registry: $ACR_NAME..."
az acr create --name $ACR_NAME --sku Basic --resource-group $RESOURCE_GROUP --admin-enabled true

echo "☁️ Creating Azure Container Apps Environment..."
az containerapp env create \
  --name $ENV_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

echo "🚀 Creating initial Container App (placeholder image)..."
az containerapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --environment $ENV_NAME \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress external \
  --cpu 0.5 --memory 1.0Gi

echo "🔐 Creating GitHub Actions deployment credentials (Service Principal)..."
az ad sp create-for-rbac --name gha-deployer --role contributor \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth > gha-creds.json

echo ""
echo "✅ Setup complete."
echo ""
echo "👉 Add the following GitHub Secrets:"
echo "  AZURE_CREDENTIALS = contents of gha-creds.json"
echo "  AZURE_RESOURCE_GROUP = $RESOURCE_GROUP"
echo "  AZURE_CONTAINER_REGISTRY = $ACR_NAME.azurecr.io"
echo "  AZURE_CONTAINERAPP_NAME = $APP_NAME"
echo "  AZURE_CONTAINERAPPS_ENVIRONMENT = $ENV_NAME"
echo ""
