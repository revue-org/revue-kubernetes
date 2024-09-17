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
echo "Deleting all Kubernetes entities..."
find specifications -name '*.yaml' -exec kubectl delete -f {} \;

# Uninstall Helm releases
echo "Uninstalling Helm charts..."
helm uninstall traefik --namespace=default
helm uninstall prometheus --namespace=default
helm uninstall grafana --namespace=default

echo "Undeployment completed."
