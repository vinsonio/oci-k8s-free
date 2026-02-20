# Site-to-Site VPN Module

## Overview

This optional module creates an **OCI IPSec VPN connection** for accessing the **private Kubernetes API endpoint** from your on-premises network.

## When Do You Need This?

**Best for:**

- Production environments requiring secure, persistent access
- Organizations with existing on-premises networks
- Teams that need high security with auditing capabilities
- Permanent, low-latency connections to the cluster

**Good alternative if:**

- Ad-hoc access is needed → Use **OCI Bastion Service** (easier, session-based)
- Testing only → Use **Public API** temporarily (less secure)

## What Gets Created

- **Dynamic Routing Gateway (DRG)** - Routes traffic between your network and OCI VCN
- **IPSec VPN Tunnel** - Encrypted connection to your on-premises network
- **Customer Premises Equipment (CPE)** reference - Represents your VPN endpoint
- **Route tables & Security lists** - Network configuration for VPN traffic
- **DRG attachment** - Connects DRG to the Kubernetes VCN

## Cost

**$0** - Site-to-Site VPN is **Always Free** (up to 50 IPSec tunnels per tenancy)

## Prerequisites

Before enabling VPN, you need:

1. **Public IP address of your VPN endpoint**
   - Could be your office firewall, VPN gateway, or cloud VPN endpoint
   - This is the `cpe_ip_address` variable

2. **Your network CIDR block**
   - e.g., `192.168.0.0/16` (all networks behind your VPN endpoint)
   - This is the `customer_network_cidr` variable

3. **VPN-capable device (CPE)**
   - Firewall, router, or VPN appliance that supports IPSec
   - Must support IKEv2 or IKEv1
   - Examples: Cisco ASA, Palo Alto, Fortinet, OpenSwan, etc.

## Setup

### 1. Find Your VPN Endpoint Information

```bash
# Your public IP (the CPE IP address)
curl https://checkip.amazonaws.com

# Your network CIDR (if not known, contact your network team)
# Common examples:
# - Office network: 203.0.113.0/24
# - VPN network: 192.168.0.0/16
```

### 2. Enable VPN in terraform.tfvars

```hcl
kubernetes_api_public_enabled = false
create_vpn                    = true
cpe_ip_address               = "203.0.113.100"         # Your VPN endpoint public IP
customer_network_cidr        = "192.168.0.0/16"        # Your on-premises network
```

### 3. Deploy

```bash
terraform apply
```

### 4. Get VPN Configuration

```bash
# View VPN setup instructions
terraform output vpn_configuration_instructions

# Get VPN connection ID
VPN_ID=$(terraform output -raw vpn_id)

# Get CPE shape ID for config download
CPE_ID=$(terraform output -raw cpe_id)
DRG_ID=$(terraform output -raw drg_id)
```

### 5. Download and Deploy CPE Configuration

```bash
# Get configuration for your CPE device type
# (e.g., Cisco ASA, Palo Alto, route-based IPSec)
oci network cpe list-cpe-device-shapes \
  --output table

# Download configuration for your CPE type
oci network virtual-circuit get-cpe-device-config \
  --cpe-device-shape-id <shape-id> \
  --ipsec-connection-id $VPN_ID \
  --output file --file-name vpn-config.txt

# Apply configuration to your VPN device (CPE)
# - Import config to your firewall/router
# - Ensure IKE and IPSec phases complete
# - Test ping to API endpoint
```

### 6. Verify VPN Tunnel is UP

```bash
# Check tunnel status
oci network ipsec-connection get --ipsec-connection-id $VPN_ID \
  --query 'data."lifecycle-state"'

# Should show: AVAILABLE

# Check tunnel details (IKE/IPSec status)
oci network ipsec-connection get --ipsec-connection-id $VPN_ID \
  --query 'data."tunnel-configuration"'
```

### 7. Test Connectivity

**From your on-premises network:**

```bash
# Ping Kubernetes API endpoint (private IP: 10.0.0.5)
ping 10.0.0.5

# SSH to a worker node
ssh -i ~/.ssh/key opc@10.0.1.X

# Test kubectl (if on a system with kubectl access)
kubectl get nodes
```

### 8. Configure kubectl

```bash
# Generate kubeconfig pointing to private API
oci ce cluster create-kubeconfig \
  --cluster-id <cluster-id> \
  --file ~/.kube/config \
  --region <region>

# Test access
kubectl get nodes
kubectl get pods --all-namespaces
```

## VPN Tunnel Troubleshooting

### Tunnel Not Coming Up

```bash
# Check tunnel phase 1 status (IKE)
oci network ipsec-status-tunnel-list --ipsec-connection-id $VPN_ID

# Check security lists allow traffic
oci network security-list list --vcn-id <vpc-id>

# Verify CPE configuration matches OCI settings
oci network cpe-device-config-question get --ipsec-connection-id $VPN_ID
```

### Can't Ping API Endpoint

```bash
# Verify route table has VPN route
oci network route-table get --route-table-id <route-table-id>

# Should have route: destination=192.168.0.0/16 → target=DRG

# Verify DRG attachment
oci network drg-attachment list --drg-id $DRG_ID
```

### Routing Issue

```bash
# VCN CIDR: 10.0.0.0/16
# API Subnet: 10.0.0.0/29
# Customer Network: 192.168.0.0/16

# Route table should have:
# 10.0.0.0/16 → Internet Gateway (for other traffic)
# 192.168.0.0/16 → DRG (for VPN traffic)
```

## Security Considerations

- **IKE Pre-shared Key** - Change default PSK in CPE config for production
- **Encryption** - Uses AES-256 (configurable in CPE)
- **Perfect Forward Secrecy** - Enable in CPE for additional security
- **Route-based vs Policy-based** - Configure per your firewall capability
- **Monitoring** - Check VCN flow logs for VPN traffic

## Monitoring VPN Connection

```bash
# View VPN metrics
oci network ipsec-status summarize-connection-stats \
  --ipsec-connection-id $VPN_ID

# Get tunnel details
oci network ipsec-connection get --ipsec-connection-id $VPN_ID

# Check encryption domain
oci network ipsec-encryption-domain-config get \
  --ipsec-connection-id $VPN_ID
```

## Disabling VPN

To remove VPN and switch to bastion or public API:

```hcl
# In terraform.tfvars:
create_vpn = false
create_bastion = true  # Or set kubernetes_api_public_enabled = true
```

```bash
terraform apply
```

## Cost Comparison

| Access Method           | Cost | Setup Time | Security               |
| ----------------------- | ---- | ---------- | ---------------------- |
| **OCI Bastion Service** | $0   | 5 min      | High (session-based)   |
| **Site-to-Site VPN**    | $0   | 30-60 min  | Very High (persistent) |
| **Public API**          | $0   | 1 min      | Low (internet-exposed) |

## References

- [OCI Site-to-Site VPN Documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/settingupipsecvpn.htm)
- [IPSec Connection Management](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingIPSecConnections.htm)
- [CPE Device Configuration](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/cpeconfiguration.htm)
- [DRG Usage](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingDRGs.htm)
- [Supported CPE Devices](https://docs.oracle.com/en-us/iaas/Content/Network/References/supportedcpes.htm)

## Common CPE Devices & Their VPN Capabilities

- **Cisco ASA/ISR** - Full support, well-documented
- **Palo Alto Networks** - Full support, policy-based preferred
- **Fortinet FortiGate** - Full support, route-based preferred
- **CheckPoint** - Full support, policy-based preferred
- **Juniper SRX** - Full support, both modes
- **OpenSwan/Libreswan** - Full support, Linux-based
- **Mikrotik RouterOS** - Full support
- **OpenVPN** - Works with route-based
