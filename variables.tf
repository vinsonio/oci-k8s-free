
variable "compartment_ocid" {
  description = "The OCID of the compartment to create resources in"
  type        = string
}

variable "region" {
  description = "The OCI region where resources will be created (e.g., us-phoenix-1)"
  type        = string
}

variable "region_identifier" {
  description = "The regional service identifier (e.g., PHX, ASH, FRA). Used to identify the Oracle Services Network for the Service Gateway."
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the cluster (e.g., v1.32.4)"
  type        = string
}

variable "cluster_name" {
  description = "The Kubernetes cluster name"
  type        = string
  default     = "cluster1"
}

variable "image_id" {
  description = "The OCID of the OS image to use for worker nodes"
  type        = string
}

variable "kubernetes_api_public_enabled" {
  description = "Whether to enable public access to Kubernetes API endpoint. Set to false for enhanced security and use VPN/bastion for admin access."
  type        = bool
  default     = false
}

variable "node_pool_size" {
  description = "Number of worker nodes in the node pool. OKE free tier supports up to 4 A1 Compute instances."
  type        = number
  default     = 4

  validation {
    condition     = var.node_pool_size > 0 && var.node_pool_size <= 4
    error_message = "The node_pool_size must be between 1 and 4 for free-tier A1 Compute instances."
  }
}

variable "allowed_k8s_api_cidrs" {
  description = "CIDR blocks allowed to access Kubernetes API. Only used when kubernetes_api_public_enabled is true. Leave empty to disable public access."
  type        = list(string)
  default     = []
}

variable "create_bastion" {
  description = "Create OCI Bastion Service for accessing private Kubernetes API. Recommended when kubernetes_api_public_enabled is false."
  type        = bool
  default     = false
}

variable "bastion_client_cidr_allow_list" {
  description = "CIDR blocks allowed to create bastion sessions. Restrict to your IP for better security."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Allow from anywhere - restrict this in production!
}

variable "create_vpn" {
  description = "Create Site-to-Site VPN for private Kubernetes API access. Requires on-premises VPN equipment."
  type        = bool
  default     = false
}

variable "cpe_ip_address" {
  description = "Public IP address of your Customer Premises Equipment (your VPN endpoint). Required if create_vpn is true."
  type        = string
  default     = ""
}

variable "customer_network_cidr" {
  description = "CIDR block of your on-premises network (e.g., 192.168.0.0/16). Required if create_vpn is true."
  type        = string
  default     = ""
}

variable "create_network_load_balancer" {
  description = "Create an OCI flexible network load balancer (Layer 4, Always Free: 1 max per tenancy) for public Kubernetes ingress. The NLB is placed in the k8s_loadbalancers subnet and forwards ports 80 and 443."
  type        = bool
  default     = false
}

variable "create_application_load_balancer" {
  description = "Create an OCI flexible application load balancer (Layer 7, Always Free: 1 × 10 Mbps max per tenancy) for public Kubernetes ingress. The ALB is placed in the k8s_loadbalancers subnet and listens on ports 80 and 443."
  type        = bool
  default     = false
}

variable "install_ingress_controller" {
  description = "Install the Traefik Ingress Controller via Helm to automatically configure external load balancing. Requires an external load balancer to be enabled."
  type        = bool
  default     = false
}

variable "lb_backend_port" {
  description = "NodePort on worker nodes that the load balancer forwards HTTP traffic to (range 30000-32767). Set to the HTTP NodePort of your ingress controller or service."
  type        = number
  default     = 30080
}

variable "lb_backend_port_https" {
  description = "NodePort on worker nodes that the load balancer forwards HTTPS traffic to (range 30000-32767). Set to the HTTPS NodePort of your ingress controller or service."
  type        = number
  default     = 30443
}

variable "create_mysql_heatwave" {
  description = "Whether to provision an OCI Always Free MySQL HeatWave DB System and Cluster."
  type        = bool
  default     = false
}

variable "mysql_admin_username" {
  description = "MySQL database admin username"
  type        = string
  default     = "admin"
}
