Write-Host "[*] Deleting Kind cluster 'vpn'..." -ForegroundColor Cyan
kind delete cluster --name vpn | Out-Null

Write-Host "[OK] Teardown complete." -ForegroundColor Green
