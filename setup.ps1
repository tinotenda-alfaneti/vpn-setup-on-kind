param(
    [string]$WG_HOST = "192.168.1.120",
    [string]$WG_PASSWORD = "ChangeMe123!"
)

Write-Host "[*] Creating Kind cluster..." -ForegroundColor Cyan
kind create cluster --config kind-wg.yaml | Out-Null

Write-Host "[*] Setting kubectl context to kind-vpn..." -ForegroundColor Cyan
kubectl config use-context kind-vpn

Write-Host "[*] Configuring wg-easy..." -ForegroundColor Cyan
kubectl create configmap wg-easy-secrets --from-literal=PASSWORD=$WG_PASSWORD
kubectl create configmap wg-config --from-literal=WG_HOST=$WG_HOST

Write-Host "[*] Creating namespace 'wg-easy'..." -ForegroundColor Cyan
kubectl create namespace wg-easy

Write-Host "[*] Applying manifests..." -ForegroundColor Cyan
kubectl apply -k manifests/ | Out-Null

Write-Host "[*] Waiting for wg-easy rollout..." -ForegroundColor Cyan
kubectl -n wg-easy rollout status deploy/wg-easy

Write-Host ""
Write-Host "[OK] VPN is ready!" -ForegroundColor Green
Write-Host "Open the web UI at: http://$WG_HOST port 51821" -ForegroundColor Yellow
Write-Host "Login with your configured password." -ForegroundColor Yellow
