# Optional Site-to-Site VPN for accessing private Kubernetes API
# This creates an IPSec VPN connection from your on-premises network to OCI VCN
# Always Free: up to 50 IPSec VPN tunnels per tenancy

resource "oci_core_cpe" "this" {
  count          = var.create_vpn ? 1 : 0
  compartment_id = var.compartment_ocid
  ip_address     = var.cpe_ip_address
  display_name   = "${var.cluster_name}-cpe"

  freeform_tags = {
    "Purpose" = "VPN to private Kubernetes API"
  }
}

resource "oci_core_drg" "this" {
  count          = var.create_vpn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${var.cluster_name}-drg"

  freeform_tags = {
    "Purpose" = "VPN to private Kubernetes API"
  }
}

resource "oci_core_drg_attachment" "vcn" {
  count        = var.create_vpn ? 1 : 0
  drg_id       = oci_core_drg.this[0].id
  vcn_id       = var.vcn_id
  display_name = "vcn-attachment"
}

resource "oci_core_ipsec" "this" {
  count          = var.create_vpn ? 1 : 0
  compartment_id = var.compartment_ocid
  cpe_id         = oci_core_cpe.this[0].id
  drg_id         = oci_core_drg.this[0].id
  static_routes  = [var.customer_network_cidr]
  display_name   = "${var.cluster_name}-vpn"

  freeform_tags = {
    "Purpose" = "VPN to private Kubernetes API"
  }
}

# Update VCN route table to route customer network through VPN
resource "oci_core_route_table" "vpn" {
  count          = var.create_vpn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "vpn-routes"

  route_rules {
    destination       = var.customer_network_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.this[0].id
  }

  freeform_tags = {
    "Purpose" = "Routes for VPN traffic"
  }
}

# Security list to allow VPN traffic to API endpoint
resource "oci_core_security_list" "vpn" {
  count          = var.create_vpn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "vpn-security-list"

  egress_security_rules {
    protocol    = "6" # TCP
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.customer_network_cidr
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 6443 # Kubernetes API
      max = 6443
    }
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = var.customer_network_cidr
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 12250 # Kubelet
      max = 12250
    }
  }

  freeform_tags = {
    "Purpose" = "VPN access to Kubernetes"
  }
}
