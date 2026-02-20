variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "cluster_name" {
  description = "Name prefix for the bastion service"
  type        = string
}

variable "create_bastion" {
  description = "Whether to create OCI Bastion Service for private API access"
  type        = bool
  default     = false
}

variable "target_subnet_id" {
  description = "Target subnet ID where bastion will connect (worker nodes subnet for K8s access)"
  type        = string
}

variable "client_cidr_allow_list" {
  description = "List of CIDR blocks allowed to connect to bastion sessions (e.g., your office/home IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Allow from anywhere - restrict this in production!
}

variable "max_session_ttl_in_seconds" {
  description = "Maximum session time-to-live in seconds (default: 3 hours)"
  type        = number
  default     = 10800 # 3 hours
}
