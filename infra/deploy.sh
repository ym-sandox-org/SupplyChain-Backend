#!/usr/bin/env bash
# =============================================================================
# deploy.sh - Deploy infra/main.bicep (App Service Plan + Web App only) using
# Azure CLI `az deployment` (NOT azd).
#
# IMPORTANT: Per task 002-infrastructure-bicep-appservice, this script is
# provided for future/manual use only. It is NOT executed as part of this
# task (provision=false). Running it requires `az login` and an existing
# resource group.
# =============================================================================
set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-rg-supplychain-backend-demo}"
LOCATION="${LOCATION:-japaneast}"
DEPLOYMENT_NAME="${DEPLOYMENT_NAME:-supplychain-backend-infra-$(date +%Y%m%d%H%M%S)}"

echo "== Bicep deployment (App Service Plan + Web App only) =="
echo "Resource Group : ${RESOURCE_GROUP}"
echo "Location       : ${LOCATION}"
echo "Deployment     : ${DEPLOYMENT_NAME}"

az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}"

az deployment group create \
  --name "${DEPLOYMENT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file "$(dirname "$0")/main.bicep" \
  --parameters "$(dirname "$0")/parameters.json"

echo "Deployment complete. Query outputs with:"
echo "  az deployment group show -g ${RESOURCE_GROUP} -n ${DEPLOYMENT_NAME} --query properties.outputs"
