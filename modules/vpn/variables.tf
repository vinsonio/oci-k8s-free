variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "cluster_name" {
  description = "Name prefix for VPN resources"
  type        = string
}

variable "create_vpn" {
  description = "Whether to create Site-to-Site VPN for private API access"
  type        = bool
  default     = false
}

variable "vcn_id" {
  description = "VCN ID where VPN will be configured"
  type        = string
}

variable "k8s_api_subnet_cidr" {
  description = "CIDR block of the Kubernetes API subnet (e.g., 10.0.0.0/29)"
  type        = string
}

variable "cpe_ip_address" {
  description = "Public IP address of your Customer Premises Equipment (your end of the VPN)"
  type        = string
  default     = ""
}

variable "customer_network_cidr" {
  description = "CIDR block of your customer network (e.g., 192.168.0.0/16)"
  type        = string
  default     = ""
}
