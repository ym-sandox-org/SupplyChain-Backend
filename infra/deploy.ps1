# =============================================================================
# deploy.ps1 - Deploy infra/main.bicep (App Service Plan + Web App only) using
# Azure CLI `az deployment` (NOT azd).
#
# IMPORTANT: Per task 002-infrastructure-bicep-appservice, this script is
# provided for future/manual use only. It is NOT executed as part of this
# task (provision=false). Running it requires `az login` and an existing
# resource group.
# =============================================================================

param(
    [string]$ResourceGroup = "rg-supplychain-backend-demo",
    [string]$Location = "japaneast",
    [string]$DeploymentName = "supplychain-backend-infra-$(Get-Date -Format yyyyMMddHHmmss)"
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Output "== Bicep deployment (App Service Plan + Web App only) =="
Write-Output "Resource Group : $ResourceGroup"
Write-Output "Location       : $Location"
Write-Output "Deployment     : $DeploymentName"

az group create `
  --name $ResourceGroup `
  --location $Location

az deployment group create `
  --name $DeploymentName `
  --resource-group $ResourceGroup `
  --template-file (Join-Path $scriptDir "main.bicep") `
  --parameters (Join-Path $scriptDir "parameters.json")

Write-Output "Deployment complete. Query outputs with:"
Write-Output "  az deployment group show -g $ResourceGroup -n $DeploymentName --query properties.outputs"
