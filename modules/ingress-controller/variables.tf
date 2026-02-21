variable "cluster_id" {
  description = "The OCID of the Kubernetes cluster"
  type        = string
}

variable "install_ingress_controller" {
  description = "Whether to install the Traefik Ingress Controller via Helm"
  type        = bool
  default     = false
}

variable "backend_port" {
  description = "The HTTP NodePort the Load Balancer forwards traffic to"
  type        = number
}

variable "backend_port_https" {
  description = "The HTTPS NodePort the Load Balancer forwards traffic to"
  type        = number
}
