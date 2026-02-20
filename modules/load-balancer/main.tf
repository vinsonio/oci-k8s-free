# OCI Load Balancer for Kubernetes ingress traffic
# Always-Free tier: 1 flexible LB at 10 Mbps minimum/maximum bandwidth
# The LB is placed in the dedicated k8s_loadbalancers subnet (10.0.2.0/24)
# which allows inbound 80/443 from the internet and egress to worker nodes.
#
# HTTPS is TCP pass-through — TLS is terminated inside the cluster
# (ingress controller / workload) to avoid managing certificates here.

resource "oci_load_balancer_load_balancer" "this" {
  count          = var.create_load_balancer ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${var.cluster_name}-lb"
  shape          = "flexible"

  # Always-Free: 10 Mbps is the minimum and maximum available in free tier
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }

  subnet_ids = [var.lb_subnet_id]

  is_private = false

  freeform_tags = {
    "Purpose" = "Public ingress load balancer for Kubernetes workloads"
  }
}

# Backend set — round-robin across worker nodes
# Health check targets kube-proxy healthz endpoint (port 10256)
# OCI CCM uses the same port to verify node readiness
resource "oci_load_balancer_backend_set" "k8s" {
  count            = var.create_load_balancer ? 1 : 0
  name             = "k8s-backends"
  load_balancer_id = oci_load_balancer_load_balancer.this[0].id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "TCP"
    port              = var.health_check_port
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }
}

# Register each worker node as a backend using its private IP
# backend_port is the NodePort exposed by your ingress controller or service
resource "oci_load_balancer_backend" "k8s_node" {
  for_each         = var.create_load_balancer ? toset(var.backend_node_ips) : []
  load_balancer_id = oci_load_balancer_load_balancer.this[0].id
  backendset_name  = oci_load_balancer_backend_set.k8s[0].name
  ip_address       = each.value
  port             = var.backend_port
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# HTTP listener on port 80
resource "oci_load_balancer_listener" "http" {
  count                    = var.create_load_balancer ? 1 : 0
  name                     = "http"
  load_balancer_id         = oci_load_balancer_load_balancer.this[0].id
  default_backend_set_name = oci_load_balancer_backend_set.k8s[0].name
  port                     = 80
  protocol                 = "TCP"
}

# HTTPS listener on port 443 (TCP pass-through — TLS terminated at cluster)
resource "oci_load_balancer_listener" "https" {
  count                    = var.create_load_balancer ? 1 : 0
  name                     = "https"
  load_balancer_id         = oci_load_balancer_load_balancer.this[0].id
  default_backend_set_name = oci_load_balancer_backend_set.k8s[0].name
  port                     = 443
  protocol                 = "TCP"
}
