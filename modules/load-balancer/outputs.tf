locals {
  lb_instructions = <<-EOT

OCI Load Balancer created: ${var.create_load_balancer ? oci_load_balancer_load_balancer.this[0].display_name : "N/A"}
Public IP: ${var.create_load_balancer ? oci_load_balancer_load_balancer.this[0].ip_address_details[0].ip_address : "N/A"}

The load balancer listens on:
  - Port 80  (HTTP, TCP pass-through)
  - Port 443 (HTTPS, TCP pass-through — TLS terminated inside cluster)

To add a worker node as a backend:
  oci lb backend create \
    --load-balancer-id ${var.create_load_balancer ? oci_load_balancer_load_balancer.this[0].id : "<LB_OCID>"} \
    --backend-set-name k8s-backends \
    --ip-address <NODE_PRIVATE_IP> \
    --port <NODEPORT>

Or deploy an ingress controller (e.g., NGINX) — OCI CCM will manage backends
automatically when you create Kubernetes Services of type LoadBalancer.

See: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm
  EOT
}

output "load_balancer_id" {
  description = "OCID of the OCI load balancer"
  value       = var.create_load_balancer ? oci_load_balancer_load_balancer.this[0].id : null
}

output "load_balancer_ip" {
  description = "Public IP address of the load balancer"
  value       = var.create_load_balancer ? oci_load_balancer_load_balancer.this[0].ip_address_details[0].ip_address : null
}

output "load_balancer_state" {
  description = "Current lifecycle state of the load balancer"
  value       = var.create_load_balancer ? oci_load_balancer_load_balancer.this[0].state : null
}

output "usage_instructions" {
  description = "Instructions for routing traffic through the load balancer"
  value       = var.create_load_balancer ? local.lb_instructions : ""
}
