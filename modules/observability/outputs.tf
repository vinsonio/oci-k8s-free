output "log_group_id" {
  description = "Log group ID"
  value       = oci_logging_log_group.k8s_main.id
}

output "log_group_name" {
  description = "Log group name"
  value       = oci_logging_log_group.k8s_main.display_name
}
