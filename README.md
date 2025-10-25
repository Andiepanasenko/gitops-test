# 🚀 GitOps Infrastructure for spam2000

Complete GitOps infrastructure solution for deploying and monitoring the spam2000 application.

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Access & Credentials](#access--credentials)
- [GitOps Workflow](#gitops-workflow)
- [Monitoring](#monitoring)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## 🎯 Overview

This project implements a complete GitOps infrastructure that meets all requirements:

- ✅ **One-command deployment**: `./setup.sh` deploys everything
- ✅ **GitOps workflow**: ArgoCD automatically syncs changes from Git
- ✅ **Monitoring system**: VictoriaMetrics + Grafana with pre-configured dashboards
- ✅ **No errors**: Robust error handling and validation
- ✅ **Auto-restart port-forward**: Automatically restarts on pod restarts

## 🛠 Tech Stack

| Component | Technology | Purpose |
| --- | --- | --- |
| **Orchestration** | Minikube | Local Kubernetes cluster |
| **Monitoring** | VictoriaMetrics | Metrics collection and storage |
| **Visualization** | Grafana | Dashboards and visualization |
| **Package Manager** | Helm | Kubernetes application management |
| **GitOps** | ArgoCD | Automatic Git synchronization |
| **Application** | spam2000 | Application that generates metrics |

## 🚀 Quick Start

### Prerequisites

```bash
# Install required tools
brew install kubectl helm minikube
```

### Installation

```bash
# Clone the repository
git clone https://github.com/Andiepanasenko/gitops-test.git
cd gitops-test

# Run the setup script (it will deploy everything and start port-forward automatically)
./setup.sh
```

The script will automatically:
- ✅ Start Minikube cluster
- ✅ Install ArgoCD for GitOps
- ✅ Install VictoriaMetrics for monitoring
- ✅ Install Grafana with pre-configured dashboards
- ✅ Deploy spam2000 application
- ✅ Start port-forward for all services with auto-restart
- ✅ Keep services running until Ctrl+C

**Execution time:** ~5-10 minutes

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     🚀 Minikube Cluster                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐     │
│  │   ArgoCD     │   │ VictoriaMetrics │  │   Grafana    │   │
│  │   (GitOps)   │   │   (Metrics DB) │  │ (Dashboards) │    │
│  └──────────────┘   └──────────────┘   └──────────────┘     │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │               spam2000 Application                    │  │
│  │  ┌──────────┐   ┌──────────┐   ┌──────────┐           │  │
│  │  │  Pod 1   │   │  Pod 2   │   │  Pod 3   │           │  │
│  │  └──────────┘   └──────────┘   └──────────┘           │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘

```

## 🔐 Access & Credentials

### ArgoCD (GitOps UI)
- **URL**: https://localhost:8080
- **Username**: `admin`
- **Password**: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

### Grafana (Monitoring)
- **URL**: http://localhost:3000
- **Username**: `admin`
- **Password**: `kubectl get secret vm-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d`

### spam2000 Application
- **URL**: http://localhost:3001
- **Metrics**: http://localhost:3001/metrics
- **No authentication required**

## 🔄 GitOps Workflow

### How It Works

1. ArgoCD monitors your Git repository
2. When configuration changes in Git, ArgoCD automatically syncs changes
3. Kubernetes resources are updated automatically

### Testing GitOps

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

3. ArgoCD will automatically detect changes and update deployment

4. Check in ArgoCD UI or with command:
   ```bash
   kubectl get pods -n spam2000
   ```

## 📊 Monitoring

### Dashboards

Two pre-configured dashboards are available:

1. **Kubernetes Cluster Overview**
   - Node CPU Usage
   - Node Memory Usage
   - Pod Status
   - Cluster Stats

2. **spam2000 Application - Golden Signals**
   - Total Metrics Generated
   - Active Pods
   - Pod Status
   - Pod CPU Usage
   - Pod Memory Usage
   - Metrics Rate
   - Container Restarts

### Metrics

Application automatically exports metrics in Prometheus format:
- `random_gauge_1` - Random gauge metric with labels
- `random_gauge_2` - Random gauge metric with labels

## 📁 Project Structure

```
gitops-test/
├── setup.sh                          # Main deployment script
├── status.sh                          # Status check utility
├── README.md                          # This documentation
│
├── helm/
│   └── spam2000/
│       ├── Chart.yaml                 # Helm chart metadata
│       ├── values.yaml                # Default configuration
│       └── templates/
│           ├── deployment.yaml        # Kubernetes Deployment
│           └── service.yaml           # Kubernetes Service
│
├── manifests/
│   ├── argocd-app.yaml               # ArgoCD Application
│   └── grafana-dashboards.yaml       # Grafana dashboards ConfigMap
│
└── dashboards/
    ├── cluster-overview.json          # Cluster dashboard
    └── spam2000-app.json             # Application dashboard (Golden Signals)
```

## ⚙️ Configuration

### Changing spam2000 Parameters

Edit `helm/spam2000/values.yaml`:

```yaml
replicas: 2                    # Number of application copies
env:
  requestRate: "10"            # Request intensity
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### Update via GitOps

```bash
# 1. Change values.yaml
# 2. Commit and push
git add helm/spam2000/values.yaml
git commit -m "Update spam2000 configuration"
git push

# 3. ArgoCD automatically syncs changes
```

## 🐛 Troubleshooting

### Check Status

```bash
./status.sh
```

### Check Pods

```bash
kubectl get pods -A
```

### Check Logs

```bash
# spam2000
kubectl logs -n spam2000 -l app=spam2000 --tail=100

# ArgoCD
kubectl logs -n argocd argocd-server-xxx

# Grafana
kubectl logs -n monitoring vm-stack-grafana-xxx
```

### Restart Services

```bash
# spam2000
kubectl rollout restart deployment/spam2000 -n spam2000

# ArgoCD
kubectl rollout restart deployment/argocd-server -n argocd

# Grafana
kubectl rollout restart deployment/vm-stack-grafana -n monitoring
```

### Port-Forward Issues

If port-forward stops working, restart it:

```bash
# Kill existing port-forwards
pkill -f "kubectl port-forward"

# Restart setup script
./setup.sh
```

## 🧹 Cleanup

### Remove All Components

```bash
# Stop Minikube (removes everything)
minikube delete
```

## 📝 Useful Commands

```bash
# Check pods
kubectl get pods -A

# Check helm releases
helm list -A

# Check application logs
kubectl logs -n spam2000 -l app=spam2000

# Restart application
kubectl rollout restart deployment/spam2000 -n spam2000

# Check ArgoCD applications
kubectl get applications -n argocd

# Check services
kubectl get svc -A
```

## 📝 License

This project was created for DevOps Engineer test assignment.

## 👤 Author

Oleksii Panasenko

## 🔗 Repository

- GitHub: https://github.com/Andiepanasenko/gitops-test

---

**Good luck with deployment! 🚀**
