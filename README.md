# K3s HA Cluster with Longhorn & Kube-VIP

This project sets up a production-like Kubernetes cluster in a lab/home environment with:

- High Availability K3s (using embedded etcd)
- Longhorn for persistent volumes
- Kube-VIP in ARP mode for a floating Virtual IP
- Traefik disabled by default (install it manually later)

---

## 🚀 Setup Instructions

### 1. Configure Your Environment

Edit the config file:

```bash
cp config/lab.env.example config/lab.env
nano config/lab.env
```

Update:
- IP addresses
- SSH username
- Path to your private key
- VIP

---

### 2. Run the Installer

```bash
source config/lab.env
bash setup/k3s_ha_longhorn_kubevip.sh
```

---

### 3. Use Your Cluster

```bash
export KUBECONFIG=$(pwd)/k3s.yaml
kubectl get nodes
```

---

## ✅ Notes

- Uses K3s in `etcd` HA mode with TLS SAN configured to VIP
- All nodes act as both **masters and workers**
- No Traefik by default
- Kube-VIP runs as static pod on each node
