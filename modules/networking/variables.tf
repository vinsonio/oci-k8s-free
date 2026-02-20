variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "region_identifier" {
  description = "Region identifier (e.g., 'US' for us-phoenix-1)"
  type        = string
}

variable "kubernetes_api_public_enabled" {
  description = "Whether to enable public access to Kubernetes API endpoint."
  type        = bool
  default     = false
}

variable "allowed_k8s_api_cidrs" {
  description = "CIDR blocks allowed to access Kubernetes API."
  type        = list(string)
  default     = []
}
