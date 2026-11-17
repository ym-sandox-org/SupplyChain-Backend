<#
.SYNOPSIS
  Deployment script for SupplyChain Backend infrastructure (App Service Plan + Web App).

.DESCRIPTION
  REVIEW-ONLY NOTE: These Bicep files were generated for manual review as part of
  task 001-infrastructure-bicep-appservice. Do not run this script against a
  subscription until the generated templates have been reviewed and the MySQL /
  RabbitMQ connection parameters have been supplied (see README.md).

.PARAMETER ResourceGroupName
  Existing resource group to deploy into.

.PARAMETER ParametersFile
  Path to the parameters JSON file (default: parameters.json in this folder).

.EXAMPLE
  ./deploy.ps1 -ResourceGroupName rg-supplychain-backend
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$ResourceGroupName,

  [string]$ParametersFile = "parameters.json",

  [string]$Location = "japaneast"
)

$ErrorActionPreference = "Stop"

Write-Host "Validating Bicep template..."
az bicep build --file main.bicep

$deploymentName = "supplychain-backend-infra-$(Get-Date -Format 'yyyyMMddHHmmss')"

Write-Host "Running what-if deployment preview against resource group: $ResourceGroupName"
az deployment group what-if `
  --resource-group $ResourceGroupName `
  --template-file main.bicep `
  --parameters "@$ParametersFile" `
  --parameters location=$Location

$confirm = Read-Host "Proceed with deployment? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
  Write-Host "Deployment cancelled."
  exit 0
}

az deployment group create `
  --name $deploymentName `
  --resource-group $ResourceGroupName `
  --template-file main.bicep `
  --parameters "@$ParametersFile" `
  --parameters location=$Location

Write-Host "Deployment complete. Review outputs above for the Web App host name."
