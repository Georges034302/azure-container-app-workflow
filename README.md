## 🚀 Node.js App on Azure Container Apps with CI/CD

This project shows how to deploy a simple Node.js web app to Azure Container Apps with GitHub Actions CI/CD.

### 📦 Features

- Simple Node.js HTTP server
- Dockerized with `Dockerfile`
- Azure setup with `setup.sh`
- GitHub Actions CI/CD (`.github/workflows/deploy.yml`)

### ✅ Prerequisites

- Azure CLI installed and logged in
- Docker installed
- GitHub repo initialized with this code
- Permissions to add GitHub secrets

### 🛠️ Step 1: Run Azure Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

### 🔐 Step 2: Add GitHub Secrets

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS` | Contents of `gha-creds.json` |
| `AZURE_RESOURCE_GROUP` | `my-rg` |
| `AZURE_CONTAINER_REGISTRY` | `<acr-name>.azurecr.io` |
| `AZURE_CONTAINERAPP_NAME` | `nodejs-app` |
| `AZURE_CONTAINERAPPS_ENVIRONMENT` | `my-container-env` |

### 🚀 Step 3: Push Code to GitHub

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

### 🌐 Access the App

```bash
az containerapp show \
  --name nodejs-app \
  --resource-group my-rg \
  --query properties.configuration.ingress.fqdn \
  -o tsv
```
👉 This command returns the FQDN (Fully Qualified Domain Name) in the following format:
```bash
🌐FQDN: <app-name>.<unique-id>.<region>.azurecontainerapps.io
```

### 🧹 Cleanup

```bash
az group delete --name my-rg --yes --no-wait
```

## 📝 License

MIT
