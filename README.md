# VPN Setup on Kind (Windows) with wg-easy

This repo spins up a **WireGuard VPN server** inside a **Kind cluster** on Windows, using [`wg-easy`](https://github.com/WeeJeWel/wg-easy).  
You’ll connect your phone via the VPN to test traffic flow.

Flow:  
**Phone → Wi-Fi → Windows host → Kind → wg-easy → Internet**

---

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (with Kubernetes disabled)  
- [Kind](https://kind.sigs.k8s.io/)  
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  
- PowerShell (run as Administrator when setting firewall rules)

---

## Step 1: Open Firewall Ports

Run PowerShell as Admin:

```powershell
New-NetFirewallRule -DisplayName "wg-udp-51820" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 51820
New-NetFirewallRule -DisplayName "wg-ui-51821" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 51821
```

---

## Step 2: Create Kind Cluster

Save as `kind-wg.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: vpn
nodes:
- role: control-plane
  extraPortMappings:
    - containerPort: 30000
      hostPort: 51820
      protocol: UDP
    - containerPort: 31821
      hostPort: 51821
      protocol: TCP
```

Create the cluster:

```powershell
kind create cluster --config kind-wg.yaml
```

---

## Step 3: Configure Kustomize

Directory layout:

```
vpn-kind/
├── kind-wg.yaml
├── manifests/
│   ├── kustomization.yaml
│   ├── wg-deploy.yaml
│   ├── wg-svc.yaml
│   ├── wg-netpol.yaml
├── setup.ps1
└── teardown.ps1
```

(See repo for full YAMLs.) Read and understand what is happening

---

## Step 4: Deploy

Use the PowerShell script:

```powershell
.\setup.ps1 -WG_HOST 192.168.1.120 -WG_PASSWORD MySecretPass!
```

It will:
- Create Kind cluster  
- Configure wg-easy with your LAN IP + password  
- Apply manifests with Kustomize  
- Print when the VPN UI is ready  

---

## Step 5: Change Parameters

Update password:

```powershell
cd manifests
kustomize edit set secret wg-easy-secrets PASSWORD=NewStrongPass!
```

Update LAN IP:

```powershell
cd manifests
kustomize edit set configmap wg-config WG_HOST=192.168.1.99
```

Reapply:

```powershell
kubectl apply -k .
```

---

## Step 6: Connect Your Phone

1. Open browser: `http://<Windows-LAN-IP>:51821`  
2. Login with your password.  
3. Add Client → Show QR → Scan with WireGuard app (iOS/Android).  
4. Activate tunnel.  

Verify with:

```powershell
kubectl -n wg-easy exec deploy/wg-easy -- wg show
```

Or visit <https://www.cloudflare.com/cdn-cgi/trace> on your phone.

---

## One-Click Scripts

### Deploy
```powershell
.\setup.ps1 -WG_HOST 192.168.1.100 -WG_PASSWORD MySecretPass!
```

### Teardown
```powershell
.\teardown.ps1
```

---

## Summary

- `setup.ps1` → Creates cluster & deploys VPN  
- `teardown.ps1` → Cleans up cluster  
- UI available at → `http://<WG_HOST>:51821`  
- WireGuard runs at → `<WG_HOST>:51820`  
