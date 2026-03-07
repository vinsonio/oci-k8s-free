variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "region_identifier" {
  description = "OCI region identifier (e.g., ap-hongkong-1)"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.30.1"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "image_id" {
  description = "OCID of the OS image for worker nodes"
  type        = string
}

variable "kubernetes_api_public_enabled" {
  description = "Whether the Kubernetes API endpoint should be publicly accessible"
  type        = bool
  default     = true
}

variable "allowed_k8s_api_cidrs" {
  description = "List of CIDR blocks allowed to access the Kubernetes API (if public)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_pool_size" {
  description = "Number of worker nodes in the node pool"
  type        = number
  default     = 1
}

variable "node_placement_ads" {
  description = "List of availability domains to place worker nodes"
  type        = list(number)
  default     = [1]
}

variable "ssh_public_key" {
  description = "SSH public key for worker nodes"
  type        = string
}

variable "create_bastion" {
  description = "Whether to create OCI Bastion Service"
  type        = bool
  default     = false
}

variable "bastion_client_cidr_allow_list" {
  description = "List of CIDR blocks allowed to access the bastion"
  type        = list(string)
  default     = []
}

variable "create_vpn" {
  description = "Whether to create Site-to-Site VPN"
  type        = bool
  default     = false
}

variable "cpe_ip_address" {
  description = "IP address of the customer premises equipment"
  type        = string
  default     = ""
}

variable "customer_network_cidr" {
  description = "CIDR block of the customer network"
  type        = string
  default     = ""
}

variable "create_network_load_balancer" {
  description = "Whether to create OCI Network Load Balancer"
  type        = bool
  default     = false
}

variable "create_application_load_balancer" {
  description = "Whether to create OCI Application Load Balancer"
  type        = bool
  default     = false
}

variable "lb_backend_port" {
  description = "Backend port for the load balancer"
  type        = number
  default     = 80
}

variable "lb_backend_port_https" {
  description = "Backend HTTPS port for the load balancer"
  type        = number
  default     = 443
}

variable "install_ingress_controller" {
  description = "Whether to install Traefik Ingress Controller"
  type        = bool
  default     = false
}

variable "create_mysql_heatwave" {
  description = "Whether to provision OCI MySQL HeatWave Always Free DB System"
  type        = bool
  default     = false
}

variable "mysql_admin_username" {
  description = "MySQL admin username"
  type        = string
  default     = "admin"
}

variable "create_autonomous_database" {
  description = "Whether to provision OCI Always Free ATP Autonomous Database"
  type        = bool
  default     = false
}

variable "autonomous_database_db_name" {
  description = "Autonomous Database name"
  type        = string
  default     = "devonbeauty"
}

variable "create_vault" {
  description = "Whether to provision OCI Vault and Master Encryption Key(s)"
  type        = bool
  default     = false
}

variable "vaults" {
  description = "Map of vaults to create. Key is a logical name, value is the configuration. If empty but create_vault is true, a default vault is created."
  type = map(object({
    name = string
  }))
  default = {
    default = {
      name = "default-vault"
    }
  }
}

variable "create_vault_secrets" {
  description = "Whether to provision OCI Vault Secrets"
  type        = bool
  default     = false
}

variable "vault_secrets" {
  description = "Map of vaults to their secrets. Key is vault logical name. Value is a map of secrets (key is secret logical name)."
  type = map(map(object({
    name           = string
    secret_content = string
  })))
  default = {}
}

variable "create_object_storage" {
  description = "Whether to provision OCI Object Storage buckets"
  type        = bool
  default     = false
}

variable "object_storage_buckets" {
  description = "Map of buckets to create. Key is logical name, value is bucket config."
  type = map(object({
    name         = string
    storage_tier = optional(string, "Standard")
    access_type  = optional(string, "NoPublicAccess")
  }))
  default = {
    default = {
      name         = "default-bucket"
      storage_tier = "Standard"
      access_type  = "NoPublicAccess"
    }
  }
}
