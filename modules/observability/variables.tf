variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster, used to scope resource display names"
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

variable "vcn_id" {
  description = "VCN ID for flow logs"
  type        = string
}
