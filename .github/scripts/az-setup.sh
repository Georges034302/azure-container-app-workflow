#!/bin/bash

set -e

# Source configuration and export variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/az-config.sh"

echo "🔧 Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "🐳 Creating Azure Container Registry: $ACR_NAME..."
az acr create --name "$ACR_NAME" --sku Basic --resource-group "$RESOURCE_GROUP" --admin-enabled true

echo "☁️ Creating Azure Container Apps Environment..."
az containerapp env create \
  --name "$ENV_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo "🚀 Creating initial Container App (placeholder image)..."
az containerapp create \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --environment "$ENV_NAME" \
  --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
  --target-port 80 \
  --ingress external \
  --cpu 0.5 --memory 1.0Gi

echo "🔐 Creating GitHub Actions deployment credentials (Service Principal)..."
az ad sp create-for-rbac --name gha-deployer --role contributor \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/"$RESOURCE_GROUP" \
  --sdk-auth > gha-creds.json

echo "🔐 Adding secrets to GitHub repository using GitHub CLI..."

if ! command -v gh &> /dev/null; then
  echo "❌ GitHub CLI (gh) not found. Please install it to add secrets automatically."
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

gh secret set AZURE_CREDENTIALS --repo "$REPO" < gha-creds.json
gh secret set AZURE_RESOURCE_GROUP --repo "$REPO" -b"$RESOURCE_GROUP"
gh secret set AZURE_CONTAINER_REGISTRY --repo "$REPO" -b"$ACR_NAME.azurecr.io"
gh secret set AZURE_CONTAINERAPP_NAME --repo "$REPO" -b"$APP_NAME"
gh secret set AZURE_CONTAINERAPPS_ENVIRONMENT --repo "$REPO" -b"$ENV_NAME"

echo ""
echo "✅ Setup complete and secrets added to GitHub repository: $REPO"