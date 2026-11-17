#!/usr/bin/env bash
# Deployment script for SupplyChain Backend infrastructure (App Service Plan + Web App).
#
# REVIEW-ONLY NOTE: These Bicep files were generated for manual review as part of
# task 001-infrastructure-bicep-appservice. Do not run this script against a
# subscription until the generated templates have been reviewed and the MySQL /
# RabbitMQ connection parameters have been supplied (see README.md).
#
# Usage:
#   ./deploy.sh <resourceGroupName> [parametersFile]
#
# Requires: az login, an existing resource group, Azure CLI >= 2.50

set -euo pipefail

RESOURCE_GROUP="${1:?Usage: ./deploy.sh <resourceGroupName> [parametersFile]}"
PARAMETERS_FILE="${2:-parameters.json}"
LOCATION="japaneast"
DEPLOYMENT_NAME="supplychain-backend-infra-$(date +%Y%m%d%H%M%S)"

echo "Validating Bicep template..."
az bicep build --file main.bicep

echo "Running what-if deployment preview against resource group: ${RESOURCE_GROUP}"
az deployment group what-if \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file main.bicep \
  --parameters "@${PARAMETERS_FILE}" \
  --parameters location="${LOCATION}"

read -p "Proceed with deployment? (y/N) " CONFIRM
if [[ "${CONFIRM}" != "y" && "${CONFIRM}" != "Y" ]]; then
  echo "Deployment cancelled."
  exit 0
fi

az deployment group create \
  --name "${DEPLOYMENT_NAME}" \
  --resource-group "${RESOURCE_GROUP}" \
  --template-file main.bicep \
  --parameters "@${PARAMETERS_FILE}" \
  --parameters location="${LOCATION}"

echo "Deployment complete. Review outputs above for the Web App host name."
