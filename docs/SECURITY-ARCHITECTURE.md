# 🔐 Security Architecture

### Kubernetes API Endpoint: **Private by Default**

**⚠️ CRITICAL:** The control plane API is **private** (not internet-accessible). **You MUST configure access** to use kubectl.

When `kubernetes_api_public_enabled = false`, you **cannot run kubectl from your laptop** without one of these solutions:

### **Choose One Access Method:**

#### Option A: OCI Bastion Service (Easiest) ✅ **Recommended for Getting Started**

Use the always-free OCI Bastion Service to create on-demand SSH sessions:

```hcl
# In terraform.tfvars:
kubernetes_api_public_enabled = false
create_bastion                = true
# bastion_client_cidr_allow_list = ["YOUR.IP.ADDRESS/32"]  # Optional: restrict to your IP
```

Then create SSH sessions to worker nodes:

```bash
# Get usage instructions
terraform output bastion_usage_instructions

# Get a worker node IP
NODE_POOL_ID=$(terraform output -raw node_pool_id)
oci ce node-pool get --node-pool-id $NODE_POOL_ID | jq -r '.data.nodes[]."private-ip"'

# Create managed SSH session (see full instructions in output above)
oci bastion session create-managed-ssh \
  --bastion-id $(terraform output -raw bastion_id) \
  --ssh-public-key-file ~/.ssh/id_rsa.pub \
  --target-resource-private-ip-address <NODE_IP> \
  --target-os-username opc

# Use kubectl on worker node (see modules/bastion/README.md for details)
```

**Cost:** $0 (OCI Bastion Service is Always Free, up to 5 bastions)

#### Option B: Site-to-Site VPN (Secure & Permanent) ✅ **Best for Production**

Create an IPSec VPN tunnel from your on-premises network to OCI (AWS, Azure, or other cloud):

```hcl
# In terraform.tfvars:
kubernetes_api_public_enabled = false
create_vpn                    = true
cpe_ip_address               = "203.0.113.100"      # Your VPN endpoint public IP
customer_network_cidr        = "192.168.0.0/16"     # Your on-premises network
```

Then deploy VPN configuration on your firewall/router and access directly:

```bash
# Get VPN setup instructions
terraform output vpn_configuration_instructions

# Verify VPN tunnel is UP
VPN_ID=$(terraform output -raw vpn_id)
oci network ipsec-connection get --ipsec-connection-id $VPN_ID \
  --query 'data."lifecycle-state"'

# Once tunnel is UP, access kubectl directly from your network
kubectl get nodes
```

**Cost:** $0 (Site-to-Site VPN is Always Free, up to 50 IPSec tunnels)

**See [modules/vpn/README.md](../modules/vpn/README.md) for detailed VPN setup guide.**

#### Option C: Temporary Public Access (Quick Testing) ⚠️

For initial testing only:

```hcl
# In terraform.tfvars:
kubernetes_api_public_enabled = true
allowed_k8s_api_cidrs        = ["0.0.0.0/0"]  # WARNING: Opens to internet
```

**After testing, switch back to private:**

```hcl
kubernetes_api_public_enabled = false  # Re-secure the API
create_bastion                = true   # Or create_vpn = true
```

### Network Security Lists

All security lists use **least-privilege, explicit port ranges**:

- **API Endpoint** — Ingress from worker/pod nodes on ports 6443 (API), 12250 (kubelet)
- **Worker Nodes** — Egress to API on 6443/12250, load balancers on 30000-32767 (NodePort services)
- **Pods** — Ingress/egress restricted to inter-pod TCP, DNS (port 53)
- **Load Balancers** — Ingress on 80/443 from internet, egress to workers on app ports

### Encryption & Hardening

✅ PV encryption in transit enabled
✅ VCN Flow Logs for traffic auditing
✅ No broad `protocol = all` rules
✅ Internet-facing subnets have NAT/Service Gateway routing

### Multi-AD Node Placement

By default all worker nodes are placed in the first availability domain (`node_placement_ads = [0]`). To spread nodes across multiple ADs for higher resilience set:

```hcl
# terraform.tfvars
node_placement_ads = [0, 1, 2]  # spread across all 3 ADs (3-AD regions only)
node_placement_ads = [0, 1]     # spread across 2 ADs
```

> **⚠️ Single-AD Regions:** If your region only has 1 Availability Domain (e.g. `ap-singapore-1`), you **must** leave this at `[0]`. Setting it to `[0, 1, 2]` will cause an "Invalid index" error during `terraform plan` or `terraform apply`.
>
> **Cost note:** Multi-AD placement has zero additional cost — the A1 Always-Free quota is a tenancy-wide OCPU/RAM pool regardless of AD distribution.
>
> **⚠️ State note:** Changing `node_placement_ads` after first apply triggers a rolling node pool replacement. Set your desired ADs before the initial `terraform apply`.
