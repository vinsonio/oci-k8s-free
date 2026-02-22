output "autonomous_database_id" {
  description = "The OCID of the Autonomous Database"
  value       = var.create_autonomous_database ? oci_database_autonomous_database.this[0].id : null
}

output "autonomous_database_connection_strings" {
  description = "Connection strings for the Autonomous Database"
  value       = var.create_autonomous_database ? oci_database_autonomous_database.this[0].connection_strings : null
}

output "autonomous_database_db_name" {
  description = "The database name of the Autonomous Database"
  value       = var.create_autonomous_database ? oci_database_autonomous_database.this[0].db_name : null
}
