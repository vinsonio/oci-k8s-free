data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_ocid
}

resource "oci_mysql_mysql_db_system" "free" {
  count = var.create_mysql_heatwave ? 1 : 0

  compartment_id      = var.compartment_ocid
  subnet_id           = var.mysql_subnet_id
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  display_name        = "AlwaysFreeMySQL"
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[0].name
  shape_name          = "MySQL.Free"

  data_storage_size_in_gb = 50

  # Crash recovery is required for Free tier, which dictates using InnoDB Cluster / HA which is not supported in Free tier,
  # or simply standing it up as a standalone DB.
  is_highly_available = false
}

resource "oci_mysql_heat_wave_cluster" "free" {
  count = var.create_mysql_heatwave ? 1 : 0

  db_system_id = oci_mysql_mysql_db_system.free[0].id
  cluster_size = 1
  shape_name   = "HeatWave.Free"
}
