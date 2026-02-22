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

variable "node_placement_ads" {
  description = "Zero-based indices of availability domains used for worker node placement. Default [0] places all nodes in the first AD. Set to e.g. [0,1,2] to spread nodes across ADs for higher resilience. Note: OCI regions have 1–3 ADs; do not specify an index that exceeds the region's AD count."
  type        = list(number)
  default     = [0]

  validation {
    condition     = length(var.node_placement_ads) > 0 && alltrue([for i in var.node_placement_ads : i >= 0])
    error_message = "The node_placement_ads must be a non-empty list of non-negative AD indices."
  }
}

variable "ssh_public_key" {
  description = "Optional SSH public key to inject into worker nodes. When set, enables direct SSH access to nodes (via OCI Bastion Service or VPN). Leave empty to disable SSH access."
  type        = string
  default     = ""
}
