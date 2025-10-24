# 🚀 Quick Start Guide

## Prerequisites

```bash
# Install required tools
brew install kubectl helm minikube
```

## Deployment

```bash
# Clone the repository
git clone https://github.com/Andiepanasenko/gitops-test.git
cd gitops-test

# Update GitHub URL in manifests/argocd-app.yaml
vim manifests/argocd-app.yaml

# Run the setup script
./setup.sh
```

## Access URLs

### ArgoCD (GitOps)
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# https://localhost:8080
# Username: admin
# Password: (run command below)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Grafana (Monitoring)
```bash
kubectl port-forward svc/grafana -n monitoring 3000:80
# http://localhost:3000
# Username: admin
# Password: admin
```

## Check Status

```bash
./status.sh
```

## GitOps Testing

1. Edit `helm/spam2000/values.yaml`:
   ```yaml
   replicas: 3  # Change from 2 to 3
   ```

2. Commit and push:
   ```bash
   git add helm/spam2000/values.yaml
   git commit -m "Scale to 3 replicas"
   git push
   ```

3. ArgoCD will auto-sync within 3 minutes

## Useful Commands

```bash
# Check pods
kubectl get pods -A

# Check helm releases
helm list -A

# Check application logs
kubectl logs -n spam2000 -l app=spam2000

# Restart application
kubectl rollout restart deployment/spam2000 -n spam2000
```

## Cleanup

```bash
# Remove all components
helm uninstall argocd -n argocd
helm uninstall victoria-metrics -n monitoring
helm uninstall grafana -n monitoring
helm uninstall spam2000 -n spam2000

# Stop Minikube
minikube stop
minikube delete
```

