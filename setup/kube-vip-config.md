# Kube-VIP (ARP Mode) Notes

Kube-VIP provides a virtual IP for the K3s HA control plane using ARP announcements.

- **ARP Mode** is ideal for lab/home networks (no BGP setup needed)
- Deploys as a **static pod** via `/etc/kubernetes/manifests/kube-vip.yaml`
- Configured to run on `eth0` (change if needed)

---

### 🧪 Example command used:

```bash
sudo kube-vip manifest pod \
  --interface eth0 \
  --address 192.168.100.200 \
  --controlplane \
  --arp \
  --leaderElection
```
