## 🚀 Node.js App on Azure Container Apps with CI/CD

This project shows how to deploy a simple Node.js web app to Azure Container Apps with GitHub Actions CI/CD.

---

### 📁 Project Structure

```
azure-container-app-workflow/
├── .github/
│   ├── workflows/
│   │   └── deploy.yml              
│   └── scripts/
│       ├── az-config.sh      # Installs Azure CLI, logs in, sets up extension, exports variables
│       ├── gh-config.sh      # Authenticates GitHub CLI and sets GH_TOKEN secret
│       ├── az-deploy.sh       # Runs az-config.sh and gh-config.sh, provisions Azure resources, sets GitHub secrets
│       └── cleanup.sh        # Removes all Azure resources and service principal
├── Dockerfile                      
├── index.js                       
├── package.json                    
└── README.md
```
---

### 📦 Features

- Simple Node.js HTTP server
- Dockerized with `Dockerfile`
- Modular Azure setup with `.github/scripts/az-config.sh`, `.github/scripts/gh-config.sh`, and `.github/scripts/az-setup.sh`
- Automated GitHub Actions CI/CD (`.github/workflows/deploy.yml`)
- Easy cleanup with `.github/scripts/cleanup.sh`

---

### ✅ Prerequisites

- Docker installed
- GitHub repo initialized with this code
- Permissions to add GitHub secrets
- [GitHub CLI](https://cli.github.com/) installed
- A GitHub Personal Access Token (PAT) exported as `GH_TOKEN` in your shell

---

### 🛠️ Step 1: Provision Azure Resources, Configure Azure & GitHub CLI, and Set GitHub Secrets

> This step will install the Azure CLI (if needed), log in, set up the Container Apps extension, authenticate the GitHub CLI, create all required Azure resources, and automatically add secrets to your GitHub repository.  
> **You only need to run `.github/scripts/az-deploy.sh`** — it will source and run both `az-config.sh` and `gh-config.sh` automatically.

```bash
chmod +x .github/scripts/az-deploy.sh
./.github/scripts/az-deploy.sh
```

---

### 🚀 Step 2: Push Code to GitHub

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

* 🤖 What Happens Next? (GitHub Actions CI/CD Explained)

After you push your code, GitHub Actions automatically triggers the workflow defined in `.github/workflows/deploy.yml`.  
This workflow will:

- **Build your Docker image** using the `Dockerfile` in your repo.
- **Push the image to Azure Container Registry** (or another registry, as configured).
- **Deploy the image to Azure Container Apps** using the Azure CLI.
- **Update the running app** with the new image version.
- **Report status** back to your GitHub repository (success/failure).

You can monitor the workflow progress under the **Actions** tab in your GitHub repository.

---

### 🌐 Step 3: Access the App

After deployment, the `.github/scripts/az-deploy.sh` script will automatically fetch and display your app's public URL (FQDN) for you.

You should see output similar to:

```bash
🌐FQDN: <app-name>.<unique-id>.<region>.azurecontainerapps.io
```

If you need to retrieve the FQDN again later, you can run:

```bash
az containerapp show \
  --name nodejs-app \
  --resource-group my-rg \
  --query properties.configuration.ingress.fqdn \
  -o tsv
```
---

### 🧹 Cleanup

```bash
chmod +x .github/scripts/cleanup.sh
./.github/scripts/cleanup.sh
```
---

### 👨‍💻 Author: Georges Bou Ghantous

This repository demonstrates automated deployment of a Node.js app to Azure Container Apps using GitHub Actions. 💙
