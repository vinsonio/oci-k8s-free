# OCI Logging configuration (Always Free: 10 GB/month shared)
# Enables security auditing and troubleshooting of network traffic

resource "oci_logging_log_group" "k8s_main" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.cluster_name}-logs"
  description    = "Log group for Kubernetes cluster networking and flow logs"
}

resource "oci_logging_log" "k8s_vcn_flow_log" {
  display_name       = "${var.cluster_name}-vcn-flow-logs"
  log_group_id       = oci_logging_log_group.k8s_main.id
  log_type           = "SERVICE"
  is_enabled         = true
  retention_duration = 30 # days; adjust to fit free quota

  configuration {
    source {
      category    = "vcn"
      resource    = var.vcn_id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
  }
}
