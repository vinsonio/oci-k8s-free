# Outputs for cluster and network resources

output "kubernetes_cluster_id" {
  description = "The OCID of the Kubernetes cluster"
  value       = module.kubernetes.cluster_id
}

output "kubernetes_cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = module.kubernetes.cluster_name
}

output "kubernetes_api_public_enabled" {
  description = "Whether the Kubernetes API endpoint is publicly accessible"
  value       = var.kubernetes_api_public_enabled
}

output "node_pool_id" {
  description = "The OCID of the node pool"
  value       = module.kubernetes.node_pool_id
}

output "node_private_ips" {
  description = "Private IP addresses of all nodes in the node pool"
  value       = module.kubernetes.node_private_ips
}


output "vcn_id" {
  description = "The OCID of the Virtual Cloud Network"
  value       = module.networking.vcn_id
}

output "k8s_api_subnet_id" {
  description = "The OCID of the Kubernetes API endpoint subnet"
  value       = module.networking.k8s_api_subnet_id
}

output "k8s_worker_nodes_subnet_id" {
  description = "The OCID of the worker nodes subnet"
  value       = module.networking.k8s_worker_nodes_subnet_id
}

output "k8s_pods_subnet_id" {
  description = "The OCID of the pods subnet"
  value       = module.networking.k8s_pods_subnet_id
}

output "k8s_loadbalancers_subnet_id" {
  description = "The OCID of the load balancers subnet"
  value       = module.networking.k8s_loadbalancers_subnet_id
}

output "network_load_balancer_id" {
  description = "OCID of the OCI network load balancer (null if not created)"
  value       = module.load_balancer.network_load_balancer_id
}

output "network_load_balancer_ip" {
  description = "Public IP address of the network load balancer (null if not created)"
  value       = module.load_balancer.network_load_balancer_ip
}

output "application_load_balancer_id" {
  description = "OCID of the OCI application load balancer (null if not created)"
  value       = module.load_balancer.application_load_balancer_id
}

output "application_load_balancer_ip" {
  description = "Public IP address of the application load balancer (null if not created)"
  value       = module.load_balancer.application_load_balancer_ip
}

output "log_group_id" {
  description = "The OCID of the logging group for VCN flow logs"
  value       = module.observability.log_group_id
}

output "bastion_id" {
  description = "OCID of the OCI Bastion Service (if created)"
  value       = module.bastion.bastion_id
}

output "bastion_name" {
  description = "Name of the bastion service (if created)"
  value       = module.bastion.bastion_name
}

output "bastion_usage_instructions" {
  description = "Instructions for using the bastion service"
  value       = module.bastion.usage_instructions
}

output "vpn_id" {
  description = "OCID of the Site-to-Site VPN connection (if created)"
  value       = module.vpn.vpn_id
}

output "vpn_status" {
  description = "Status of the VPN connection (if created)"
  value       = module.vpn.vpn_status
}

output "vpn_configuration_instructions" {
  description = "Instructions for configuring VPN"
  value       = module.vpn.vpn_configuration_instructions
}

output "connection_instructions" {
  description = "Instructions for connecting to the cluster"
  value = var.kubernetes_api_public_enabled ? (
    "API is publicly accessible. Use 'oci ce cluster create-kubeconfig --cluster-id ${module.kubernetes.cluster_id} --file $HOME/.kube/config --region ${var.region}'"
    ) : var.create_bastion ? (
    "API is private. Use OCI Bastion Service to connect to worker nodes. Run 'terraform output bastion_usage_instructions' for details."
    ) : (
    "⚠️  API is private but no bastion created. Set create_bastion=true, use VPN, or temporarily enable public API. See README.md"
  )
}

output "mysql_db_system_id" {
  description = "The OCID of the MySQL DB System"
  value       = module.mysql.mysql_db_system_id
}

output "mysql_db_system_endpoints" {
  description = "The endpoints of the MySQL DB System (IP address and port)"
  value       = module.mysql.mysql_db_system_endpoints
}

output "mysql_heatwave_cluster_id" {
  description = "The OCID of the MySQL HeatWave Cluster"
  value       = module.mysql.mysql_heatwave_cluster_id
}

output "mysql_admin_password" {
  description = "The randomly generated MySQL admin password"
  value       = var.create_mysql_heatwave ? random_password.mysql_admin[0].result : null
  sensitive   = true
}
