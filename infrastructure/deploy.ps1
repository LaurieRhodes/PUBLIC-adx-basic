# Deploy ADX Cluster with ASIM Scripts
param(
    [Parameter(Mandatory=$true)]
    [string]$resourceGroupName,
    
    [Parameter(Mandatory=$false)]
    [string]$location = "australiasoutheast",
    
    [Parameter(Mandatory=$false)]
    [string]$templateFile = "main.bicep",
    
    [Parameter(Mandatory=$false)]
    [string]$parametersFile = "parameters.json"
)

# Check if Az module is installed
if (-not (Get-Module -ListAvailable Az.Accounts)) {
    Write-Host "Azure PowerShell module not found. Installing..."
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
}

# Import Az module
Import-Module Az

# Check if logged into Azure
$context = $null
try {
    $context = Get-AzContext
}
catch {
    $context = $null
}

if (-not $context) {
    Write-Host "Not logged into Azure. Please login..."
    Connect-AzAccount
}

# Alternative approach using Azure CLI if Az PowerShell module installation fails
function Test-CommandExists {
    param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try { if (Get-Command $command) { return $true } }
    catch { return $false }
    finally { $ErrorActionPreference = $oldPreference }
}

# Check if Azure CLI is available as fallback
$useAzureCLI = $false
if (-not (Get-Module -ListAvailable Az)) {
    if (Test-CommandExists 'az') {
        $useAzureCLI = $true
        Write-Host "Using Azure CLI as fallback..."
        
        # Check Azure CLI login status
        $azLoginStatus = az account show 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Not logged into Azure CLI. Please login..."
            az login
        }
    }
    else {
        Write-Error "Neither Azure PowerShell nor Azure CLI is available. Please install one of them."
        exit 1
    }
}

if ($useAzureCLI) {
    # Using Azure CLI commands
    Write-Host "Checking if resource group exists..."
    $rg = az group show --name $resourceGroupName 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Creating resource group $resourceGroupName in $location..."
        az group create --name $resourceGroupName --location $location
    }

    Write-Host "Starting deployment of $templateFile..."
    $deployment = az deployment group create `
        --name "adx-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')" `
        --resource-group $resourceGroupName `
        --template-file $templateFile `
        --parameters "@$parametersFile"

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Deployment failed. Error: $deployment"
        exit 1
    }
}
else {
    # Using Azure PowerShell commands
    Write-Host "Checking if resource group exists..."
    $rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Host "Creating resource group $resourceGroupName in $location..."
        New-AzResourceGroup -Name $resourceGroupName -Location $location
    }

    Write-Host "Starting deployment of $templateFile..."
    $deployment = New-AzResourceGroupDeployment `
        -Name "adx-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')" `
        -ResourceGroupName $resourceGroupName `
        -TemplateFile $templateFile `
        -TemplateParameterFile $parametersFile

    if ($deployment.ProvisioningState -eq "Failed") {
        Write-Error "Deployment failed. Error: $($deployment.Error)"
        exit 1
    }

    Write-Host "Deployment completed with status: $($deployment.ProvisioningState)"
}

Write-Host "Deployment process completed"