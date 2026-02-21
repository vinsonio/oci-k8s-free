output "network_load_balancer_id" {
  description = "OCID of the OCI network load balancer"
  value       = var.create_network_load_balancer ? oci_network_load_balancer_network_load_balancer.this[0].id : null
}

output "network_load_balancer_ip" {
  description = "Public IP address of the network load balancer"
  value       = var.create_network_load_balancer ? oci_network_load_balancer_network_load_balancer.this[0].ip_addresses[0].ip_address : null
}

output "application_load_balancer_id" {
  description = "OCID of the OCI application load balancer"
  value       = var.create_application_load_balancer ? oci_load_balancer_load_balancer.this[0].id : null
}

output "application_load_balancer_ip" {
  description = "Public IP address of the application load balancer"
  value       = var.create_application_load_balancer ? oci_load_balancer_load_balancer.this[0].ip_address_details[0].ip_address : null
}

