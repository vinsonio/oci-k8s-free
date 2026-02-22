# OCI Always Free ATP Autonomous Database
# Always-Free tier: up to 2 ADB instances per tenancy, 20 GB storage each
# db_workload = "OLTP" → ATP (Transaction Processing)
# compute_model = "ECPU" with compute_count = 2 → Always Free allocation

resource "oci_database_autonomous_database" "this" {
  count = var.create_autonomous_database ? 1 : 0

  compartment_id = var.compartment_ocid
  db_name        = var.db_name
  display_name   = var.display_name
  admin_password = var.admin_password

  db_workload             = "OLTP"
  is_free_tier            = true
  license_model           = "LICENSE_INCLUDED"
  compute_model           = "ECPU"
  compute_count           = 2
  data_storage_size_in_gb = 20

  subnet_id                   = var.adb_subnet_id
  is_mtls_connection_required = true

  freeform_tags = {
    "Purpose" = "Always Free ATP Autonomous Database"
  }
}
