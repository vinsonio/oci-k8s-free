# OCI Bastion Service Module

## Overview

This optional module creates an **OCI Bastion Service** (managed service) for accessing the **private Kubernetes API endpoint** via SSH tunneling to worker nodes.

## When Do You Need This?

**You NEED this (or an alternative) when:**

- `kubernetes_api_public_enabled = false` (the secure default)
- You want to run `kubectl` commands to manage your cluster

**Without bastion access to a private API, you cannot:**

- Deploy applications with `kubectl apply`
- View logs with `kubectl logs`
- Execute commands in pods
- View node status

## What Gets Created

- **OCI Bastion Service** (managed service by Oracle)
  - Fully managed - no compute instances to maintain
  - Creates secure SSH tunnels on-demand
  - Connects to your worker nodes subnet
  - Sessions are temporary and audited

## Cost

**$0** - OCI Bastion Service is **Always Free** (up to 5 bastions per tenancy).

## Usage

### 1. Enable in terraform.tfvars

```hcl
# In terraform.tfvars:
kubernetes_api_public_enabled = false
create_bastion                = true

# Optional: Restrict bastion access to your IP only (recommended for production)
# bastion_client_cidr_allow_list = ["203.0.113.0/32"]  # Replace with your public IP
```

### 2. Deploy

```bash
terraform apply
```

### 3. Get Bastion Service OCID

```bash
# View bastion usage instructions
terraform output bastion_usage_instructions

# Get bastion OCID
terraform output bastion_id
```

### 4. Create a Bastion Session (On-Demand)

**Step 1: Get a worker node private IP**

```bash
# Get node pool OCID from terraform output
NODE_POOL_ID=$(terraform output -raw node_pool_id)

# List worker nodes and their private IPs
oci ce node-pool get --node-pool-id $NODE_POOL_ID \
  --query 'data.nodes[].{name:name, ip:"private-ip", state:"lifecycle-state"}' \
  --output table

# Save a worker node IP
NODE_IP="10.0.2.X"  # Use one from the output above
```

**Step 2: Create managed SSH session**

```bash
BASTION_ID=$(terraform output -raw bastion_id)

oci bastion session create-managed-ssh \
  --bastion-id $BASTION_ID \
  --ssh-public-key-file ~/.ssh/id_rsa.pub \
  --target-resource-private-ip-address $NODE_IP \
  --target-os-username opc \
  --display-name "kubectl-access" \
  --session-ttl-in-seconds 10800

# Save the session OCID from output
SESSION_ID="ocid1.bastionsession.oc1...."
```

**Step 3: Wait for session to become ACTIVE**

```bash
# Check session state
oci bastion session get --session-id $SESSION_ID \
  --query 'data."lifecycle-state"'

# Wait until it shows "ACTIVE" (usually ~30 seconds)
```

**Step 4: Get SSH connection command**

```bash
# Get the SSH command with ProxyCommand
oci bastion session get --session-id $SESSION_ID \
  --query 'data."ssh-metadata".command' \
  --raw-output

# Example output:
# ssh -i <privateKey> -o ProxyCommand="ssh -i <privateKey> -W %h:%p -p 22 ocid1.bastionsession.oc1...@host.bastion.ap-singapore-1.oci.oraclecloud.com" -p 22 opc@10.0.2.X
```

**Step 5: Connect to worker node**

```bash
# Use the SSH command from previous step
ssh -i ~/.ssh/id_rsa \
  -o ProxyCommand="ssh -i ~/.ssh/id_rsa -W %h:%p -p 22 $SESSION_ID@host.bastion.ap-singapore-1.oci.oraclecloud.com" \
  opc@$NODE_IP
```

### 5. Run kubectl on Worker Node

Once connected to a worker node via bastion session:

```bash
# kubectl is already installed on worker nodes
sudo kubectl get nodes --kubeconfig /etc/kubernetes/kubelet.conf

# Or configure your own kubeconfig
mkdir -p ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

kubectl get nodes
kubectl get pods --all-namespaces
```

## Managing the Cluster via Bastion

Once connected to a worker node, you can manage the cluster:

```bash
# Deploy applications
kubectl apply -f deployment.yaml

# View resources
kubectl get pods --all-namespaces
kubectl get services
kubectl get deployments

# View logs
kubectl logs <pod-name>

# Execute commands in pods
kubectl exec -it <pod-name> -- /bin/bash
```

## Session Management

### List Active Sessions

```bash
BASTION_ID=$(terraform output -raw bastion_id)
oci bastion session list --bastion-id $BASTION_ID \
  --session-lifecycle-state ACTIVE \
  --output table
```

### Delete a Session

```bash
oci bastion session delete --session-id $SESSION_ID
```

### Session Expiry

- Sessions automatically expire after the configured TTL (default: 3 hours)
- Maximum TTL: 180 minutes (3 hours)
- Create new sessions as needed - they're free!

## Disabling the Bastion Service

If you later set up VPN or switch to public API:

```hcl
# In terraform.tfvars:
create_bastion = false
```

```bash
terraform apply
```

The bastion service will be destroyed.

## Alternative Access Methods

Instead of OCI Bastion Service, you can use:

1. **Site-to-Site VPN** - Connect your network to OCI VCN (requires FastConnect or VPN setup - may incur costs)
2. **Public API** - Set `kubernetes_api_public_enabled = true` (less secure, easier for testing)
3. **CloudShell** - Use OCI Console's built-in shell (limited capabilities)

## Advantages of OCI Bastion Service

- **Free** - No compute costs
- **Secure** - Temporary sessions with audit logs
- **Managed** - No patching or maintenance required
- **No Public IPs** - Targets remain private
- **Session Recording** - Optional session logging for compliance

## Troubleshooting

### Session Creation Fails

```bash
# Check that the bastion service is ACTIVE
oci bastion bastion get --bastion-id $BASTION_ID --query 'data."lifecycle-state"'

# Verify target subnet is correct (should be worker nodes subnet)
terraform output bastion_id
```

### Can't Connect to Worker Node

```bash
# Ensure worker nodes are ACTIVE
oci ce node-pool get --node-pool-id $NODE_POOL_ID \
  --query 'data.nodes[]."lifecycle-state"'

# Verify security list allows SSH from bastion subnet
# Worker nodes subnet should allow ingress on port 22 from worker subnet CIDR
```

### kubectl Not Working on Worker Node

```bash
# Worker nodes have kubectl pre-installed with kubeconfig
sudo kubectl get nodes --kubeconfig /etc/kubernetes/kubelet.conf

# If you need cluster-admin access, copy the admin config
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

### Session Timeout Too Short

```hcl
# In terraform.tfvars or module call:
max_session_ttl_in_seconds = 10800  # 3 hours (maximum)
```

## References

- [OCI Bastion Service Documentation](https://docs.oracle.com/en-us/iaas/Content/Bastion/home.htm)
- [Managing Bastion Sessions](https://docs.oracle.com/en-us/iaas/Content/Bastion/Tasks/managingsessions.htm)
- [Always Free Resources](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)

# Regenerate kubeconfig

oci ce cluster create-kubeconfig \
 --cluster-id $CLUSTER_ID \
 --file ~/.kube/config \
 --overwrite

# Check cluster is reachable from bastion

kubectl cluster-info

````

### Want to Copy Files to Bastion

```bash
# Copy kubeconfig manifests
scp -i ~/.ssh/your_key deployment.yaml opc@<bastion-ip>:~/

# Copy from bastion
scp -i ~/.ssh/your_key opc@<bastion-ip>:~/logs.txt ./
````

## Security Best Practices

✅ Use strong SSH keys (RSA 4096-bit or ED25519)  
✅ Restrict SSH access via security list to your IP only  
✅ Keep bastion OS updated: `sudo dnf update -y`  
✅ Use SSH key forwarding instead of storing keys on bastion  
✅ Rotate SSH keys periodically

**Alternative:** OCI Bastion Service (managed) is also Always Free (up to 5 bastions). It's more secure (session-based, time-limited access) but this self-managed option is better for permanent kubectl access with custom tools installed.

## See Also

- [README.md](../README.md) - Main setup guide
- [ARCHITECTURE.md](../docs/ARCHITECTURE.md) - Network architecture
- [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - Common issues
