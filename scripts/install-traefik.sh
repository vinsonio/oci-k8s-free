#!/bin/bash

# install-traefik.sh
# Installs Traefik Ingress Controller via Helm for the example app.

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=============================================${NC}"
echo -e "${GREEN}   Traefik Ingress Controller Installer      ${NC}"
echo -e "${BLUE}=============================================${NC}"

# Check for helm
if ! command -v helm &> /dev/null; then
    echo "Error: helm is not installed. Please install helm first."
    exit 1
fi

# Check for kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed. Please install kubectl first."
    exit 1
fi

echo -e "${BLUE}[1/3] Adding Traefik Helm repository...${NC}"
helm repo add traefik https://traefik.github.io/charts
helm repo update

echo -e "${BLUE}[2/3] Creating 'traefik' namespace...${NC}"
kubectl create namespace traefik --dry-run=client -o yaml | kubectl apply -f -

echo -e "${BLUE}[3/3] Installing/Upgrading Traefik...${NC}"
# We set ingressClass parameters to match what examples/app/ingress.yaml expects (ingressClassName: traefik)
# OCI LoadBalancer annotations can be added here if needed, but defaults usually work for public LBs.
helm upgrade --install traefik traefik/traefik \
    --namespace traefik \
    --set ingressClass.enabled=true \
    --set ingressClass.isDefaultClass=false \
    --set service.annotations."service\.beta\.kubernetes\.io/oci-load-balancer-shape"="flexible" \
    --set service.annotations."service\.beta\.kubernetes\.io/oci-load-balancer-shape-min"="10" \
    --set service.annotations."service\.beta\.kubernetes\.io/oci-load-balancer-shape-max"="100"

echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}   Traefik installation complete!            ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo "Verify functionality:"
echo "  kubectl get svc -n traefik"
echo "  kubectl get ingressclasses"
