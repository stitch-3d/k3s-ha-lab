#!/bin/bash

set -e

# Load config
source $(dirname "$0")/../config/lab.env

echo "[+] Bootstrapping primary node (${NODES[0]})"
ssh -i $SSH_KEY $USER@${NODES[0]} << EOF
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION \
  INSTALL_K3S_EXEC="server --cluster-init --disable traefik --tls-san $VIRTUAL_IP" \
  sh -
EOF

echo "[+] Getting K3s token"
TOKEN=$(ssh -i $SSH_KEY $USER@${NODES[0]} "sudo cat /var/lib/rancher/k3s/server/node-token")

for NODE in "${NODES[@]:1}"; do
  echo "[+] Joining node: $NODE"
  ssh -i $SSH_KEY $USER@$NODE << EOF
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$K3S_VERSION \
  INSTALL_K3S_EXEC="server --disable traefik --tls-san $VIRTUAL_IP" \
  K3S_URL=https://$VIRTUAL_IP:6443 K3S_TOKEN=$TOKEN sh -
EOF
done

echo "[+] Downloading kubeconfig"
scp -i $SSH_KEY $USER@${NODES[0]}:/etc/rancher/k3s/k3s.yaml ./k3s.yaml
sed -i.bak "s/127.0.0.1/$VIRTUAL_IP/" ./k3s.yaml

echo "[+] Deploying kube-vip on all nodes"
for NODE in "${NODES[@]}"; do
  ssh -i $SSH_KEY $USER@$NODE << EOF
sudo ctr image pull ghcr.io/kube-vip/kube-vip:v0.6.4
sudo mkdir -p /etc/kubernetes/manifests
sudo kube-vip manifest pod \
  --interface eth0 \
  --address $VIRTUAL_IP \
  --controlplane \
  --arp \
  --leaderElection | sudo tee /etc/kubernetes/manifests/kube-vip.yaml
EOF
done

echo "[+] Installing Longhorn..."
kubectl --kubeconfig ./k3s.yaml create namespace longhorn-system
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system

echo "[✅] Done! K3s HA cluster with VIP and Longhorn is ready."
