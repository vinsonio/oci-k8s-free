output "vcn_id" {
  description = "VCN ID"
  value       = oci_core_virtual_network.k8s_vcn.id
}

output "k8s_api_subnet_id" {
  description = "Kubernetes API endpoint subnet ID"
  value       = oci_core_subnet.k8s_api.id
}

output "k8s_api_subnet_cidr" {
  description = "Kubernetes API subnet CIDR block (for VPN routing)"
  value       = local.subnets.k8s_api.cidr_block
}

output "k8s_worker_nodes_subnet_id" {
  description = "Worker nodes subnet ID"
  value       = oci_core_subnet.k8s_worker_nodes.id
}

output "k8s_pods_subnet_id" {
  description = "Pods subnet ID"
  value       = oci_core_subnet.k8s_pods.id
}

output "k8s_loadbalancers_subnet_id" {
  description = "Load balancers subnet ID"
  value       = oci_core_subnet.k8s_loadbalancers.id
}
