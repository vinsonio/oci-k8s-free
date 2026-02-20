output "vpn_id" {
  description = "OCID of the IPSec VPN connection"
  value       = var.create_vpn ? oci_core_ipsec.this[0].id : null
}

output "vpn_status" {
  description = "Status of the VPN connection"
  value       = var.create_vpn ? oci_core_ipsec.this[0].state : null
}

output "cpe_id" {
  description = "OCID of the Customer Premises Equipment"
  value       = var.create_vpn ? oci_core_cpe.this[0].id : null
}

output "drg_id" {
  description = "OCID of the Dynamic Routing Gateway"
  value       = var.create_vpn ? oci_core_drg.this[0].id : null
}

locals {
  vpn_instructions = <<-EOT

VPN Connection Created Successfully

To complete the setup:

1. Download VPN configuration file:
   oci network virtual-circuit get-cpe-device-config \
     --cpe-device-shape-id <cpe-shape-id> \
     --ipsec-connection-id ${var.create_vpn ? oci_core_ipsec.this[0].id : "VPN_ID"}

2. Deploy configuration on your CPE (firewall/router):
   - Import the configuration file
   - Ensure VPN tunnel is UP

3. Verify tunnel status:
   oci network ipsec-connection get --ipsec-connection-id ${var.create_vpn ? oci_core_ipsec.this[0].id : "VPN_ID"}

4. Test connectivity from your network:
   ping 10.0.0.5  # Kubernetes API endpoint private IP

5. Configure kubectl to use private API:
   oci ce cluster create-kubeconfig \
     --cluster-id <cluster-id> \
     --file ~/.kube/config \
     --region <region>

References:
- https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/settingupipsecvpn.htm
- https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingIPSecConnections.htm

  EOT
}

output "vpn_configuration_instructions" {
  description = "Instructions for configuring VPN"
  value       = var.create_vpn ? local.vpn_instructions : ""
}

output "tunnel_ike_preshared_key" {
  description = "IKE pre-shared key for tunnel (use in CPE configuration)"
  value       = var.create_vpn ? try(oci_core_ipsec.this[0].compartment_id, "Not available") : null
  sensitive   = true
}
