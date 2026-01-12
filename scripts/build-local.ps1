# Build Script for Trubanb Microservices
# This script builds all 4 microservices with the 'local' tag for use with Docker Desktop Kubernetes
# Run from: trubanb-infra directory

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Trubanb Local Build Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Get the root directory (parent of trubanb-infra)
$rootDir = Split-Path -Parent $PSScriptRoot
$rootDir = Split-Path -Parent $rootDir

$services = @(
    @{Name="User Service"; Path="$rootDir\trubanb-user-service"; Image="trubanb-user-service:local"},
    @{Name="Accommodation Service"; Path="$rootDir\trubanb-accommodation-service"; Image="trubanb-accommodation-service:local"},
    @{Name="Reservation Service"; Path="$rootDir\trubanb-reservation-service"; Image="trubanb-reservation-service:local"},
    @{Name="Rating Service"; Path="$rootDir\trubanb-rating-service"; Image="trubanb-rating-service:local"}
)

$successCount = 0
$failedServices = @()

foreach ($service in $services) {
    Write-Host "Building $($service.Name)..." -ForegroundColor Yellow
    Write-Host "  Path: $($service.Path)" -ForegroundColor Gray
    Write-Host "  Image: $($service.Image)" -ForegroundColor Gray

    try {
        Set-Location $service.Path
        docker build -t $service.Image . 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ $($service.Name) built successfully`n" -ForegroundColor Green
            $successCount++
        } else {
            throw "Docker build failed with exit code $LASTEXITCODE"
        }
    }
    catch {
        Write-Host "  ✗ Failed to build $($service.Name)" -ForegroundColor Red
        Write-Host "    Error: $_`n" -ForegroundColor Red
        $failedServices += $service.Name
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Build Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Successfully built: $successCount/$($services.Count) services" -ForegroundColor $(if ($successCount -eq $services.Count) { "Green" } else { "Yellow" })

if ($failedServices.Count -gt 0) {
    Write-Host "Failed services:" -ForegroundColor Red
    foreach ($failed in $failedServices) {
        Write-Host "  - $failed" -ForegroundColor Red
    }
    Write-Host ""
    exit 1
}

Write-Host "`nAll images built successfully!`n" -ForegroundColor Green

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Verify images: " -NoNewline -ForegroundColor Gray
Write-Host "docker images | Select-String 'trubanb'" -ForegroundColor White
Write-Host "  2. Deploy to Kubernetes:" -ForegroundColor Gray
Write-Host "     cd kubernetes\umbrella-chart" -ForegroundColor White
Write-Host "     helm upgrade --install trubanb . -f ../environments/values-local.yaml --create-namespace --namespace trubanb-dev" -ForegroundColor White
Write-Host "  3. Check deployment: " -NoNewline -ForegroundColor Gray
Write-Host "kubectl get pods -n trubanb-dev" -ForegroundColor White
Write-Host ""

# Return to original directory
Set-Location $PSScriptRoot