#!/bin/bash

export RESOURCE_GROUP="my-rg"
export LOCATION="australiaeast"
export ACR_NAME="myacr$RANDOM"
export APP_NAME="nodejs-app"
export ENV_NAME="my-container-env"

echo "🔧 Installing Azure CLI (if not present)..."
if ! command -v az &> /dev/null; then
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
else
  echo "✅ Azure CLI already installed."
fi

echo "🔑 Logging in to Azure using device code..."
az login --use-device-code

echo "📋 Fetching Azure subscription list and setting the first one as default..."
FIRST_SUBSCRIPTION_ID=$(az account list --query '[0].id' -o tsv)
az account set --subscription "$FIRST_SUBSCRIPTION_ID"
export SUBSCRIPTION_ID="$FIRST_SUBSCRIPTION_ID"
echo "✅ Default subscription set to: $FIRST_SUBSCRIPTION_ID"

echo "📦 Ensuring Azure CLI Container Apps extension is installed..."
az extension add --name containerapp --yes

echo "✅ Azure CLI and Container Apps extension are ready."