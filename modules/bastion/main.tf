# OCI Bastion Service for accessing private Kubernetes API
# This creates a managed bastion service (Always Free)
# that can be used to create SSH sessions to worker nodes for kubectl access

resource "oci_bastion_bastion" "k8s_bastion" {
  count                        = var.create_bastion ? 1 : 0
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = var.target_subnet_id
  client_cidr_block_allow_list = var.client_cidr_allow_list
  name                         = "${var.cluster_name}-bastion"
  max_session_ttl_in_seconds   = var.max_session_ttl_in_seconds

  freeform_tags = {
    "Purpose" = "Bastion for private Kubernetes API and worker node access"
  }
}
