[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$expectedNamespace = 'k8s-30d'
$currentContext = kubectl config current-context
Write-Host "Current context: $currentContext" -ForegroundColor Yellow

if (-not $Force) {
    $answer = Read-Host "Delete namespace '$expectedNamespace' and everything in it? Type delete"
    if ($answer -ne 'delete') {
        Write-Host 'No changes made.'
        exit 0
    }
}

kubectl delete namespace $expectedNamespace --ignore-not-found=true
Write-Host 'Namespaced lab resources were removed. Review k8s-30d-* cluster-scoped objects separately.' -ForegroundColor Green

