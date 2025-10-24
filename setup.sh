#!/bin/bash

echo "🚀 Starting GitOps Infrastructure Setup..."
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to wait for pods to be ready
wait_for_pods() {
    local namespace=$1
    local timeout=${2:-180}
    local count=0
    
    print_status "Waiting for pods in namespace $namespace to be ready..."
    while [ $count -lt $timeout ]; do
        local ready=$(kubectl get pods -n $namespace -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' | grep -c True || true)
        local total=$(kubectl get pods -n $namespace --no-headers 2>/dev/null | wc -l | tr -d ' ')
        
        if [ "$total" -gt 0 ] && [ "$ready" -eq "$total" ]; then
            print_status "All pods in $namespace are ready!"
            return 0
        fi
        
        sleep 2
        count=$((count + 2))
    done
    
    print_warning "Timeout waiting for pods in $namespace"
    return 0
}

print_status "Step 1/8: Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { print_error "kubectl is required but not installed. Aborting."; exit 1; }
command -v helm >/dev/null 2>&1 || { print_error "helm is required but not installed. Aborting."; exit 1; }
command -v minikube >/dev/null 2>&1 || { print_error "minikube is required but not installed. Aborting."; exit 1; }

print_status "Step 2/8: Starting Minikube..."
if ! minikube status >/dev/null 2>&1; then
    print_status "Starting new Minikube cluster..."
    minikube start --cpus=2 --memory=4096 --disk-size=20g
else
    print_status "Minikube is already running"
fi

print_status "Enabling metrics-server addon..."
minikube addons enable metrics-server || print_warning "Metrics-server may already be enabled"

print_status "Step 3/8: Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
print_status "Adding Argo Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm || print_warning "Repository may already exist"
helm repo update
print_status "Installing ArgoCD..."
helm upgrade --install argocd argo/argo-cd \
    --namespace argocd \
    --set server.service.type=LoadBalancer

wait_for_pods argocd 300

print_status "Step 4/8: Installing VictoriaMetrics and Prometheus..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
print_status "Adding VictoriaMetrics Helm repository..."
helm repo add vm https://victoriametrics.github.io/helm-charts/ || print_warning "Repository may already exist"
helm repo update
print_status "Installing VictoriaMetrics..."
helm upgrade --install victoria-metrics vm/victoria-metrics-k8s-stack \
    --namespace monitoring \
    --set victoria-metrics-k8s-stack.prometheus.enabled=true \
    --set victoria-metrics-k8s-stack.victoria-metrics-k8s-stack-grafana.enabled=true \
    --set victoria-metrics-k8s-stack.victoria-metrics-k8s-stack-prometheus.enabled=true

wait_for_pods monitoring 300

print_status "Step 5/8: Deploying spam2000 application..."
kubectl create namespace spam2000 --dry-run=client -o yaml | kubectl apply -f -
print_status "Deploying spam2000..."
helm upgrade --install spam2000 ./helm/spam2000 \
    --namespace spam2000

wait_for_pods spam2000 180

print_status "Step 6/8: Configuring GitOps with ArgoCD..."
if [ -f manifests/argocd-app.yaml ]; then
    print_warning "Skipping ArgoCD application deployment - please update GitHub URL in manifests/argocd-app.yaml"
    print_warning "After updating the URL, run: kubectl apply -f manifests/argocd-app.yaml"
else
    print_warning "ArgoCD application manifest not found"
fi

print_status "Step 7/8: Configuring Grafana dashboards..."
kubectl apply -f manifests/grafana-dashboards.yaml

print_status "Step 8/8: Getting ArgoCD admin password..."
sleep 5
ARGO_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "Please check: kubectl -n argocd get secret argocd-initial-admin-secret")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}✨ Setup Complete! ✨${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Access ArgoCD:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   URL: https://localhost:8080"
echo "   Username: admin"
echo "   Password: $ARGO_PASSWORD"
echo ""
echo "📈 Access Grafana:"
echo "   kubectl port-forward svc/grafana -n monitoring 3000:80"
echo "   URL: http://localhost:3000"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "🔍 Check application status:"
echo "   kubectl get pods -n spam2000"
echo "   kubectl get pods -n monitoring"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

