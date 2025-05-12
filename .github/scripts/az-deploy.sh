#!/bin/bash

set -e

# Source configuration and export variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 Sourcing Azure CLI and environment configuration..."
source "$SCRIPT_DIR/az-config.sh"
echo "✅ Finished az-config.sh"

echo "🔑 Sourcing GitHub CLI authentication and configuration..."
source "$SCRIPT_DIR/gh-config.sh"
echo "✅ Finished gh-config.sh"

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
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/"$RESOURCE_GROUP" \
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
gh secret set AZURE_CONTAINER_REGISTRY_NAME --repo "$REPO" -b"$ACR_NAME"
gh secret set AZURE_CONTAINERAPP_NAME --repo "$REPO" -b"$APP_NAME"
gh secret set AZURE_CONTAINERAPPS_ENVIRONMENT --repo "$REPO" -b"$ENV_NAME"

# Assign AcrPull role to the Container App's managed identity
echo ""
echo "🔑 Assigning AcrPull role to the Container App's managed identity..."
PRINCIPAL_ID=$(az containerapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query identity.principalId \
  -o tsv)

ACR_ID=$(az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --query id -o tsv)

if [[ -n "$PRINCIPAL_ID" && -n "$ACR_ID" ]]; then
  az role assignment create \
    --assignee "$PRINCIPAL_ID" \
    --role "AcrPull" \
    --scope "$ACR_ID"
  echo "✅ AcrPull role assigned."
else
  echo "⚠️  Could not assign AcrPull role (missing principal ID or ACR ID)."
fi

echo ""
echo "✅ Setup complete and secrets added to GitHub repository: $REPO"

echo ""
echo "🌐 Fetching the public URL (FQDN) of your Azure Container App..."
APP_FQDN=$(az containerapp show \
  --name "$APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query properties.configuration.ingress.fqdn \
  -o tsv)

if [[ -n "$APP_FQDN" ]]; then
  echo "🌐 Your app is available at: https://$APP_FQDN"
else
  echo "⚠️  Could not retrieve the FQDN for your container app."
fi