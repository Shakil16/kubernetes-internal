[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$expectedNamespace = 'k8s-30d'
$manifest = Join-Path $PSScriptRoot 'manifests\00-namespace.yaml'

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw 'kubectl is not installed or is not on PATH.'
}

$currentContext = kubectl config current-context
if (-not $currentContext) {
    throw 'No kubectl context is selected.'
}

Write-Host "Current context: $currentContext" -ForegroundColor Yellow
kubectl cluster-info | Out-Host

if (-not $Force) {
    $answer = Read-Host "Create/update namespace '$expectedNamespace' in this context? Type yes"
    if ($answer -ne 'yes') {
        Write-Host 'No changes made.'
        exit 0
    }
}

kubectl apply -f $manifest
kubectl config set-context --current --namespace=$expectedNamespace | Out-Host
kubectl get namespace $expectedNamespace
Write-Host 'Lab namespace is ready.' -ForegroundColor Green

