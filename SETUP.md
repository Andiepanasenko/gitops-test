# GitOps Setup Instructions

## Before Running setup.sh

### 1. Update ArgoCD Application Configuration

Edit `manifests/argocd-app.yaml` and replace the placeholder with your actual GitHub repository URL:

```yaml
spec:
  source:
    repoURL: https://github.com/YOUR_USERNAME/pdffiller-infra.git  # ← Update this
```

### 2. For Local Testing (Optional)

If you want to test GitOps locally without pushing to GitHub, you can use a local Git repository:

```yaml
spec:
  source:
    repoURL: https://github.com/YOUR_USERNAME/pdffiller-infra.git
    # Or use local path for testing:
    # path: helm/spam2000
```

### 3. Alternative: Manual Deployment

If you prefer not to use ArgoCD for GitOps, you can comment out the ArgoCD installation step in `setup.sh` and manually deploy:

```bash
# Comment out ArgoCD installation in setup.sh, then:
helm upgrade --install spam2000 ./helm/spam2000 --namespace spam2000 --create-namespace
```

## Quick Start

1. Update the GitHub URL in `manifests/argocd-app.yaml`
2. Run `./setup.sh`
3. Access ArgoCD and Grafana using the URLs provided after setup

## Testing GitOps

After setup, make changes to `helm/spam2000/values.yaml`:

```bash
# Edit values.yaml
vim helm/spam2000/values.yaml

# Commit and push
git add helm/spam2000/values.yaml
git commit -m "Update configuration"
git push

# ArgoCD will automatically sync within 3 minutes
```

