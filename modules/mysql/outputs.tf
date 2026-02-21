output "mysql_db_system_id" {
  description = "The OCID of the MySQL DB System"
  value       = var.create_mysql_heatwave ? oci_mysql_mysql_db_system.free[0].id : null
}

output "mysql_db_system_endpoints" {
  description = "The endpoints of the MySQL DB System"
  value       = var.create_mysql_heatwave ? oci_mysql_mysql_db_system.free[0].endpoints : []
}

output "mysql_heatwave_cluster_id" {
  description = "The OCID of the MySQL HeatWave Cluster"
  value       = var.create_mysql_heatwave ? oci_mysql_heat_wave_cluster.free[0].id : null
}
