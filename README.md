# Create a Free Managed Kubernetes Cluster in Oracle Cloud using Terraform

Deploy a secure, production-hardened Kubernetes cluster on Oracle Cloud Infrastructure's **Always-Free tier** with Terraform, staying completely within free-tier constraints while implementing security best practices.

---

## 🎯 Features

- **100% Free Tier** — Uses OKE Basic (free), A1 Compute, and Always-Free networking + logging
- **Secure by Default** — Private Kubernetes API endpoint, encrypted traffic, least-privilege security lists
- **Network Segmentation** — Dedicated subnets for API, worker nodes, pods, and load balancers
- **Observability** — VCN Flow Logs for security auditing (10 GB/month Always-Free quota)
- **High Availability** — Multi-AD node placement via `node_placement_ads` at zero extra cost; easy scaling within free tier limits
- **Databases Included** — Optional Always-Free MySQL HeatWave and ATP Autonomous Database modules
- **SSH Access** — Optional SSH key injection into worker nodes for direct access via Bastion/VPN
- **Parameterized** — Typed variables, validation, and clear configuration

📖 **See [Complete Always Free Resources Guide](docs/ALWAYS-FREE-RESOURCES.md)** for detailed quota information

---

## 📋 Prerequisites

1. **Oracle Cloud Account** — Free-tier account with Always-Free resources enabled
2. **Terraform** — v1.0+ installed locally
3. **OCI CLI** — For retrieving kubeconfig credentials
4. **SSH keypair** (optional) — For worker node access

### Step 1: Set Up OCI Credentials

```bash
mkdir -p ~/.oci
# Download your private key from OCI Console → User Settings → API Keys
# Place it in ~/.oci/oci_api_key.pem
# Create ~/.oci/config with your tenancy and user details
```

Reference: [OCI SDK Authentication](https://docs.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm)

---

## 🚀 Quick Start

### Step 2: Configure Backend (Optional)

Using OCI Object Storage for remote state is recommended. You can generate the required **S3-compatible credentials** using the OCI CLI:

```bash
# 1. Get your User OCID (if not known)
USER_OCID=$(oci iam user get --user-id <your-user-ocid> --query "data.id" --output string)

# 2. Create the Customer Secret Key
oci iam customer-secret-key create --user-id $USER_OCID --display-name "terraform-backend"

# 3. Copy the 'key' (Secret Key) and 'id' (Access Key ID) from the output
```

**Benefits of remote state:**
- ✅ State accessible from any machine/CI/CD
- ✅ Automatic versioning and encryption
- ✅ Still 100% Always Free (20 GB storage quota)

### Step 3: Find Your Image OCID

During setup, you'll need an OS image OCID. You can list available Oracle Linux images with:

```bash
oci compute image list --compartment-id $COMPARTMENT_OCID --region us-phoenix-1 \
  --query "data[?contains(\"display_name\", 'Oracle-Linux-9')].{id:id,name:\"display_name\"}" \
  --output table
```

### Step 4: Deploy

Once configured, review your `terraform.tfvars` and run:

```bash
# If using remote state, source your environment
source .terraform.env

# Preview and apply
terraform plan
terraform apply
```

Cluster creation typically takes **5-10 minutes**. Monitor progress in OCI Console → Developer Services → Kubernetes Clusters.

---

## 🔐 Security Architecture

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

**See [modules/vpn/README.md](modules/vpn/README.md) for detailed VPN setup guide.**

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

> **Cost note:** Multi-AD placement has zero additional cost — the A1 Always-Free quota is a tenancy-wide OCPU/RAM pool regardless of AD distribution.
>
> **⚠️ State note:** Changing `node_placement_ads` after first apply triggers a rolling node pool replacement. Set your desired ADs before the initial `terraform apply`.

---

## 📊 Monitoring & Observability

### VCN Flow Logs (Always-Free: 10 GB/month)

View network traffic flowing through the cluster:

```bash
# Query flow logs in OCI Console → Logging → Logs
# Useful for troubleshooting and security investigations
oci logging log-content get \
  --log-id <log-id-from-outputs> \
  --log-group-id <log-group-id-from-outputs>
```

---

## 🚢 Example App

After provisioning your cluster, deploy a ready-made nginx example to validate end-to-end networking and ingress:

```bash
kubectl apply -f examples/app/
kubectl rollout status deployment/example-app -n example-app
```

The example exercises the full stack: Pod → Service → Ingress → OCI Flexible Load Balancer. It uses `nginx:stable-alpine` which is compatible with the ARM-based `VM.Standard.A1.Flex` nodes.

📖 **See [examples/app/README.md](examples/app/README.md)** for full deploy, verify, and teardown instructions.

---

## 🛠️ Accessing the Cluster

### Step 1: Generate Kubeconfig

```bash
CLUSTER_ID=$(terraform output -raw kubernetes_cluster_id)
REGION=$(terraform output -raw region)

oci ce cluster create-kubeconfig \
  --cluster-id $CLUSTER_ID \
  --file $HOME/.kube/config \
  --region $REGION
```

### Step 2: Verify Connectivity

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

If the API is private, ensure your connection method is configured (VPN, bastion, or allowlist).

---

## 🖥️ Accessing Worker Nodes (SSH)

### Private Node Access Warning ℹ️

You'll see this warning in OCI Console: **"Accessing your private nodes: set up a bastion host"**

This is **expected and correct** - your worker nodes are in private subnets (10.0.1.0/24) and cannot be accessed directly from the internet. This is the secure default configuration.

### SSH Key Injection

To enable SSH access, set an SSH public key before your first `terraform apply`:

```hcl
# terraform.tfvars
ssh_public_key = "ssh-rsa AAAA..."   # your ~/.ssh/id_rsa.pub or similar
```

> **⚠️ State note:** Setting or changing `ssh_public_key` on an existing cluster triggers a node pool update. Set it before the initial `terraform apply` to avoid disruption.

### When Do You Need SSH Access?

**Most users DON'T need SSH access** to worker nodes. Kubernetes operations happen via `kubectl`, not SSH:

- Deploy applications: `kubectl apply`
- View logs: `kubectl logs`
- Debug pods: `kubectl exec -it <pod> -- /bin/bash`

### If You Need SSH Access (Advanced)

**Option 1: OCI Bastion Service (Managed)** ✅ **Recommended - Always Free**

```bash
# Always Free: Up to 5 OCI Bastions per tenancy
# Most secure option - session-based access with time limits

# 1. Create a Bastion in OCI Console
# Navigation: Identity & Security → Bastion → Create Bastion
# - Select your VCN (from terraform outputs)
# - Select k8s_worker_nodes subnet (private subnet)
# - CIDR allowlist: Your IP (e.g., 203.0.113.0/32)

# 2. Create SSH Session
# In Console: Bastion → Sessions → Create Session
# - Session type: Port forwarding or Managed SSH
# - Target: Private IP of worker node
# - Port: 22
# - Max session TTL: e.g., 3 hours

# 3. Connect using the provided SSH command
ssh -i ~/.ssh/id_rsa -N -L 2222:<worker-private-ip>:22 -p 22 ocid1.bastionsession.xxx@host
ssh -p 2222 -i ~/.ssh/worker_key opc@localhost
```

**Alternative:** See `modules/bastion/README.md` for detailed OCI Bastion Service usage including:

- Creating temporary sessions
- Session management
- kubectl access via worker nodes

**Option 3: kubectl debug** (No SSH needed)

```bash
# 1. Create a small A1 compute instance in the k8s_loadbalancers subnet (public)
# 2. SSH to the jump box from your machine
# 3. From jump box, SSH to worker nodes using private IPs
ssh -i ~/.ssh/worker_key opc@10.0.1.x
```

```bash
# Run a debug container on a worker node (requires kubectl access)
kubectl debug node/<node-name> -it --image=ubuntu
```

**💰 Cost Comparison:**

- **OCI Bastion Service (Option 1):** $0 - Always Free (up to 5 bastions) ✅
- **kubectl debug (Option 2):** $0 - no bastion needed ✅

**Recommendation:** Use **OCI Bastion Service** (Option 1) for managed, secure access with session-based auditing and automatic cleanup.

**Bottom line:** The warning is confirmation of good security - acknowledge it and only set up bastion access if you truly need direct SSH access to nodes.

---

## �💰 Cost Estimation

**All Always-Free services:**

| Resource                   | Always Free Quota        | This Project Uses        | Cost   |
| -------------------------- | ------------------------ | ------------------------ | ------ |
| OKE Cluster (Basic)        | 1 cluster                | 1 cluster                | $0     |
| A1 Compute (Ampere ARM)    | 4 OCPU + 24 GB RAM total | 4 × 1 OCPU (6 GB each)   | $0     |
| Block Storage              | 200 GB total             | ~120 GB (boot volumes)   | $0     |
| VCN + Subnets              | Included                 | 1 VCN, 4 subnets         | $0     |
| Public IP Addresses        | Included                 | 1 (load balancer subnet) | $0     |
| Load Balancer              | 1 ALB **OR** 1 NLB       | Optional (for ingress)   | $0     |
| Outbound Data Transfer     | 10 TB/month              | ~1-10 GB/month           | $0     |
| VCN Flow Logs              | 10 GB/month              | Enabled (monitoring)     | $0     |
| Logging                    | 10 GB ingestion/month    | ~1-5 GB/month            | $0     |
| Bastion Service            | Up to 5 bastions         | Optional (SSH to nodes)  | $0     |
| MySQL HeatWave DB System   | 1 ECPU, 50GB Storage     | Optional                 | $0     |
| MySQL HeatWave Cluster     | 1 Node, 16GB Memory      | Optional                 | $0     |
| Monitoring & Notifications | Included                 | Basic metrics            | $0     |
| **Total Monthly Cost**     | **—**                    | **—**                    | **$0** |

### Optional Add-ons (Additional Costs)

| Resource                              | Cost                     | When Needed              |
| ------------------------------------- | ------------------------ | ------------------------ |
| Additional A1 compute (beyond 4 OCPU) | ~$0.01/OCPU-hour         | Scaling beyond free tier |
| Block storage (beyond 200 GB)         | ~$0.0255/GB-month        | Large persistent volumes |
| Enhanced OKE cluster (vs Basic)       | ~$0.10/hour (~$73/month) | Advanced K8s features    |

### Always Free Resources NOT Used

These are available if you want to extend the setup:

- **2 × Oracle Autonomous Databases** (20 GB each, ATP or ADW)
- **2 × VM.Standard.E2.1.Micro** (AMD x86 instances)
- **10 GB Object Storage** (for backups/artifacts)
- **10 GB Archive Storage** (long-term retention)
- **5 × OCI Bastion Service** instances (for SSH to private resources)

**Note:** Always Free resources verified from https://www.oracle.com/cloud/free/ (Feb 2026)

📖 **See [docs/ALWAYS-FREE-RESOURCES.md](docs/ALWAYS-FREE-RESOURCES.md)** for complete Always Free tier details and verification commands.

---

## 🛠️ Development & Contributing

### CI/CD

This project uses GitHub Actions for automated linting and validation:
- **Terraform Format Check**: Ensures idiomatic code style
- **Terraform Validate**: Checks for configuration validity
- **TFLint**: Catches provider-specific issues and best practices

### Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) and our [Code of Conduct](CODE_OF_CONDUCT.md).

## 🗑️ Cleanup

```bash
terraform destroy
```

---

## 📝 Configuration Options

### `terraform.tfvars` Options

```hcl
# Core OCI credentials
compartment_ocid = "ocid1.compartment.oc1...your-compartment-ocid..."
region           = "us-phoenix-1"  # us-ashburn-1, eu-frankfurt-1, ...
region_identifier = "US"  # Identifies service gateway for your region
kubernetes_version = "v1.28.0"
cluster_name       = "cluster1"
image_id         = "ocid1.image.oc1...linux-image-ocid..."

# Security
kubernetes_api_public_enabled = false  # Set to true only for dev/lab
allowed_k8s_api_cidrs = ["203.0.113.0/24"]  # Only used if public_enabled=true

# Scaling (1-4 nodes for free tier A1 Compute)
node_pool_size = 4

# Multi-AD placement (zero extra cost; set before first apply to avoid node replacement)
# node_placement_ads = [0, 1, 2]  # spread across ADs (3-AD regions)

# SSH access to worker nodes (set before first apply)
# ssh_public_key = "ssh-rsa AAAA..."

# Database
create_mysql_heatwave = false        # Set to true to create Always Free MySQL DB System
# mysql_admin_username  = "admin"    # Admin username

create_autonomous_database = false   # Set to true to create Always Free ATP Autonomous Database
# autonomous_database_db_name = "appdb"  # DB name (alphanumeric, 14 chars max)
```

### Variables with Validation

All variables include:

- Type enforcement
- Descriptions
- Validation rules (e.g., node_pool_size ∈ [1,4])

---

## 🚨 Important Notes

### Free Tier Constraints

- **A1 Compute**: 3,000 OCPU-hours/month shared. A 1-OCPU instance runs ~125 days (3000 hrs/month ÷ 4 nodes ÷ 24 hrs/day).
- **Network**: 10 TB outbound data transfer/month (per tenancy), VCN Flow Logs shared quota.
- **Scale carefully** — Adding nodes exceeds free tier and incurs charges.

### Security Best Practices

1. **Keep API private** — Enable public only for development with strict IP allowlists.
2. **Use VPN for production** — Site-to-Site VPN is free and secure.
3. **Monitor flow logs** — Review VCN Flow Logs regularly for unauthorized access attempts.
4. **Implement RBAC** — Kubernetes RBAC is your responsibility; configure serviceaccounts and roles.
5. **Patch regularly** — Update Kubernetes and node images through OKE console.

---

## 📖 References

- [OCI Always-Free Services](https://www.oracle.com/cloud/free/)
- [OKE Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/home.htm)
- [OCI VCN & Networking](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/overview.htm)
- [VPN Site-to-Site Setup](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/settingupipsecvpn.htm)
- [OCI Logging & OCI Audit](https://docs.oracle.com/en-us/iaas/Content/Logging/home.htm)

---

## 🤝 Contributing

Found issues or enhancements? Please open an issue or PR.

## 📄 License

This project is licensed under the [MIT License](LICENSE).
