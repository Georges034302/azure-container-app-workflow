#!/bin/bash

set -e

# --- Config ---
HOSTNAME="github.com"
export OWNER=$(gh api user --jq .login)
echo "GitHub user: $OWNER"
export REPO=$(basename -s .git "$(git config --get remote.origin.url)")
echo "Current repo name: $REPO"
export REPO_FULL="$OWNER/$REPO"

# --- Unset GH_TOKEN and GITHUB_TOKEN to avoid conflicts ---
unset GITHUB_TOKEN

echo "🔐 Logging into GitHub CLI with GH_TOKEN from environment..."
echo "$GH_TOKEN" | gh auth login --hostname "$HOSTNAME" --with-token

echo "✅ gh auth login completed"

# --- Verify login ---
gh auth status

# --- Set repository secrets (will prompt for value if GH_TOKEN is not set) ---
echo "🔐 Setting repository secrets..."
gh secret set GH_TOKEN --repo "$REPO_FULL"

echo "✅ GH_TOKEN set and GitHub CLI authenticated successfully."