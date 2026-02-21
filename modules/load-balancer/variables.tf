variable "compartment_ocid" {
  description = "OCID of the compartment to create the load balancer in"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name used as a display-name prefix for the load balancer"
  type        = string
}

variable "create_network_load_balancer" {
  description = "Create an OCI flexible network load balancer (L4, Always Free: 1 per tenancy) for public Kubernetes ingress. Set to true to enable."
  type        = bool
  default     = false
}

variable "create_application_load_balancer" {
  description = "Create an OCI flexible application load balancer (L7, Always Free: 1 × 10 Mbps per tenancy) for public Kubernetes ingress. Set to true to enable."
  type        = bool
  default     = false
}

variable "lb_subnet_id" {
  description = "OCID of the load-balancer subnet (k8s_loadbalancers) from the networking module"
  type        = string
}

variable "health_check_port" {
  description = "TCP port used by the backend health checker. Default 10256 is the kube-proxy healthz port, which OCI CCM also uses to verify node readiness."
  type        = number
  default     = 10256
}

variable "backend_node_ips" {
  description = "Private IP addresses of worker nodes to register as load balancer backends. Pass module.kubernetes.node_private_ips from the root module."
  type        = list(string)
  default     = []
}

variable "backend_port" {
  description = "NodePort on worker nodes that the load balancer forwards HTTP traffic to. Must be in range 30000-32767. Set to the HTTP NodePort exposed by your ingress controller (e.g., NGINX on 30080)."
  type        = number
  default     = 30080

  validation {
    condition     = var.backend_port >= 30000 && var.backend_port <= 32767
    error_message = "The backend_port must be a valid Kubernetes NodePort in the range 30000-32767."
  }
}

variable "backend_port_https" {
  description = "NodePort on worker nodes that the load balancer forwards HTTPS traffic to. Must be in range 30000-32767. Set to the HTTPS NodePort exposed by your ingress controller (e.g., NGINX on 30443)."
  type        = number
  default     = 30443

  validation {
    condition     = var.backend_port_https >= 30000 && var.backend_port_https <= 32767
    error_message = "The backend_port_https must be a valid Kubernetes NodePort in the range 30000-32767."
  }
}
