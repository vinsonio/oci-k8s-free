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

variable "create_mysql_heatwave" {
  description = "Whether to create a dedicated subnet and security rules for MySQL HeatWave."
  type        = bool
  default     = false
}
