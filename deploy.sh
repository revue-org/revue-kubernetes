#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0"
  exit 1
}

# Check if no arguments were provided
if [ $# -ne 0 ]; then
  usage
fi

# Helm setup and deployment of Traefik, Prometheus, and Grafana
helm repo add traefik https://traefik.github.io/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Traefik with the specified namespace
helm install traefik traefik/traefik --namespace=default # --values gateway/traefik-values.yaml
helm install prometheus prometheus-community/prometheus -f prometheus/prometheus-values.yaml
helm install grafana grafana/grafana -f prometheus/grafana-values.yaml

# Apply all YAML configuration files in the 'specifications' folder
echo "Applying all Kubernetes specifications..."
find specifications -name '*.yaml' -exec kubectl apply -f {} \;

echo "Deployment completed."