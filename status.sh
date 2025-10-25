#!/bin/bash

echo "GitOps Infrastructure Status"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Minikube
echo "Checking Minikube..."
if minikube status >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Minikube is running"
    minikube status | grep -E "host|kubelet|apiserver"
else
    echo -e "${RED}✗${NC} Minikube is not running"
fi
echo ""

# Check ArgoCD
echo "Checking ArgoCD..."
if kubectl get namespace argocd >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} ArgoCD namespace exists"
    kubectl get pods -n argocd
else
    echo -e "${RED}✗${NC} ArgoCD namespace not found"
fi
echo ""

# Check Monitoring
echo "Checking Monitoring..."
if kubectl get namespace monitoring >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Monitoring namespace exists"
    kubectl get pods -n monitoring
else
    echo -e "${RED}✗${NC} Monitoring namespace not found"
fi
echo ""

# Check spam2000
echo "Checking spam2000 Application..."
if kubectl get namespace spam2000 >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} spam2000 namespace exists"
    kubectl get pods -n spam2000
else
    echo -e "${RED}✗${NC} spam2000 namespace not found"
fi
echo ""

# Check Helm releases
echo "Checking Helm Releases..."
helm list -A
echo ""

echo "Quick Access Commands:"
echo "  ArgoCD:  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Grafana: kubectl port-forward svc/grafana -n monitoring 3000:80"
echo ""
