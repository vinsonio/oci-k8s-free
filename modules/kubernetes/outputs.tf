output "cluster_id" {
  description = "Kubernetes cluster ID"
  value       = oci_containerengine_cluster.cluster1.id
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = oci_containerengine_cluster.cluster1.name
}

output "node_pool_id" {
  description = "Node pool ID"
  value       = oci_containerengine_node_pool.pool1.id
}

output "node_private_ips" {
  description = "Private IP addresses of all nodes in the pool"
  value       = oci_containerengine_node_pool.pool1.nodes[*].private_ip
}
