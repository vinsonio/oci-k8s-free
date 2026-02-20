variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "cluster1"
}

variable "image_id" {
  description = "Node image ID"
  type        = string
}

variable "kubernetes_api_public_enabled" {
  description = "Whether Kubernetes API is public"
  type        = bool
}

variable "node_pool_size" {
  description = "Number of nodes in the pool"
  type        = number
}

variable "vcn_id" {
  description = "VCN ID"
  type        = string
}

variable "k8s_api_subnet_id" {
  description = "Kubernetes API subnet ID"
  type        = string
}

variable "k8s_worker_nodes_subnet_id" {
  description = "Worker nodes subnet ID"
  type        = string
}

variable "k8s_pods_subnet_id" {
  description = "Pods subnet ID"
  type        = string
}

variable "k8s_loadbalancers_subnet_id" {
  description = "Load balancers subnet ID"
  type        = string
}
