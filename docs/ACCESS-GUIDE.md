# 🛠️ Access Guide

This guide covers how to access your Kubernetes cluster, worker nodes, and the optionally provisioned MySQL HeatWave database.

---

## Accessing the Cluster

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

## 🗄️ Accessing the Database (MySQL HeatWave)

The optionally provisioned Oracle MySQL HeatWave Database resides in a private subnet, so it cannot be reached directly from your local machine. You must use the OCI Bastion Service to establish a port-forwarding session to the database.

**Option 1: Automated Instructions (Recommended)**
If you enable `create_bastion = true` and `create_mysql_heatwave = true`, Terraform will automatically generate the required OCI CLI commands for you:
```bash
terraform output -raw mysql_bastion_connection_instructions
```

**Option 2: Manual Port Forwarding via OCI Console**
1. Ensure the Bastion Service is created (either via Terraform or manually in the `k8s_worker_nodes` subnet).
2. Go to Identity & Security → Bastion → <Your Bastion>.
3. Click **Create Session**.
   - Session Type: **Port Forwarding**
   - Target IP: The private IP address of your MySQL DB System (retrieve via `terraform output mysql_db_system_endpoints`)
   - Target Port: **3306**
   - Provide your SSH public key.
4. Copy the SSH command provided by the session details, replacing `<privateKey>` with the path to your key, and run it locally.
5. Connect to the forwarded port locally:
```bash
mysql -h 127.0.0.1 -P 3306 -u admin -p
# Provide the auto-generated password retrieved via 'terraform output mysql_admin_password'
```
