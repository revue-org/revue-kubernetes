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

# Delete all Kubernetes resources from the 'specifications' folder
echo "Deleting all Kubernetes specifications..."
find specifications -name '*.yaml' -exec kubectl delete -f {} \;

# Uninstall Helm releases
echo "Uninstalling Helm charts..."
helm uninstall traefik --namespace=traefik
helm uninstall prometheus
helm uninstall grafana

echo "Undeployment completed."
