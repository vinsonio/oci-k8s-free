locals {
  subnets = {
    k8s_api = {
      cidr_block = "10.0.0.0/29"
    },
    k8s_worker_nodes = {
      cidr_block = "10.0.1.0/24"
    },
    k8s_pods = {
      cidr_block = "10.0.32.0/19"
    },
    k8s_loadbalancers = {
      cidr_block = "10.0.2.0/24"
    },
    mysql = {
      cidr_block = "10.0.3.0/24"
    }
  }

  lowercase_region_identifier = lower(var.region_identifier)

  uppercase_region_identifier = upper(var.region_identifier)
}

data "oci_core_services" "this" {
  filter {
    name   = "name"
    values = ["All ${local.uppercase_region_identifier} Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_virtual_network" "k8s_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "k8sVCN"
  dns_label      = "k8svcn"
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_ocid
  display_name   = "internet-gateway-0"
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "nat-gateway-0"
}

resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "service-gateway-0"

  services {
    service_id = data.oci_core_services.this.services[0]["id"]
  }
}

resource "oci_core_subnet" "k8s_api" {
  cidr_block        = local.subnets.k8s_api.cidr_block
  display_name      = "KubernetesAPIendpoint"
  dns_label         = "kubernetesapi"
  security_list_ids = [oci_core_security_list.k8s_api.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.k8s_vcn.id
  route_table_id    = oci_core_route_table.k8s_api.id
  dhcp_options_id   = oci_core_virtual_network.k8s_vcn.default_dhcp_options_id
}

resource "oci_core_route_table" "k8s_api" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "routetable-KubernetesAPIendpoint"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_security_list" "k8s_api" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "seclist-KubernetesAPIendpoint"

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_worker_nodes.cidr_block

    tcp_options {
      max = "10250"
      min = "10250"
    }
  }

  egress_security_rules {
    protocol    = "1"
    destination = local.subnets.k8s_worker_nodes.cidr_block

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_pods.cidr_block

    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_pods.cidr_block

    tcp_options {
      max = "12250"
      min = "12250"
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"
  }

  egress_security_rules {
    protocol         = "1"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_worker_nodes.cidr_block

    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_worker_nodes.cidr_block

    tcp_options {
      max = "12250"
      min = "12250"
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = local.subnets.k8s_worker_nodes.cidr_block

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_pods.cidr_block

    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_pods.cidr_block

    tcp_options {
      max = "12250"
      min = "12250"
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.kubernetes_api_public_enabled ? var.allowed_k8s_api_cidrs : []
    content {
      protocol = "6"
      source   = ingress_security_rules.value

      tcp_options {
        max = "6443"
        min = "6443"
      }
    }
  }
}

resource "oci_core_subnet" "k8s_worker_nodes" {
  cidr_block                = local.subnets.k8s_worker_nodes.cidr_block
  display_name              = "workernodes"
  dns_label                 = "workernodes"
  security_list_ids         = [oci_core_security_list.k8s_worker_nodes.id]
  compartment_id            = var.compartment_ocid
  vcn_id                    = oci_core_virtual_network.k8s_vcn.id
  route_table_id            = oci_core_route_table.k8s_worker_nodes.id
  dhcp_options_id           = oci_core_virtual_network.k8s_vcn.default_dhcp_options_id
  prohibit_internet_ingress = true
}

resource "oci_core_route_table" "k8s_worker_nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "routetable-workernodes"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }

  route_rules {
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"
    network_entity_id = oci_core_service_gateway.this.id
  }
}

resource "oci_core_security_list" "k8s_worker_nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "seclist-workernodes"

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_api.cidr_block

    tcp_options {
      max = "12250"
      min = "12250"
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_api.cidr_block

    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_pods.cidr_block

    tcp_options {
      max = "53"
      min = "53"
    }
  }

  egress_security_rules {
    protocol    = "17"
    destination = local.subnets.k8s_pods.cidr_block

    udp_options {
      max = "53"
      min = "53"
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"
  }

  egress_security_rules {
    protocol    = "all"
    destination = local.subnets.k8s_pods.cidr_block
  }

  egress_security_rules {
    protocol         = "1"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"

    icmp_options {
      type = 3
      code = 4
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.create_mysql_heatwave ? [1] : []
    content {
      protocol    = "6"
      destination = local.subnets.mysql.cidr_block
      tcp_options {
        max = "3306"
        min = "3306"
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.create_mysql_heatwave ? [1] : []
    content {
      protocol    = "6"
      destination = local.subnets.mysql.cidr_block
      tcp_options {
        max = "33060"
        min = "33060"
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_api.cidr_block

    tcp_options {
      max = "10250"
      min = "10250"
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_loadbalancers.cidr_block

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_loadbalancers.cidr_block

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_loadbalancers.cidr_block

    tcp_options {
      max = "32767"
      min = "30000"
    }
  }

  # Allow OCI LB health checker to reach kube-proxy healthz (port 10256)
  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_loadbalancers.cidr_block

    tcp_options {
      max = "10256"
      min = "10256"
    }
  }

  ingress_security_rules {
    protocol = "all"
    source   = local.subnets.k8s_pods.cidr_block
  }
}

resource "oci_core_subnet" "k8s_pods" {
  cidr_block                = local.subnets.k8s_pods.cidr_block
  display_name              = "pods"
  dns_label                 = "pods"
  security_list_ids         = [oci_core_security_list.k8s_pods.id]
  compartment_id            = var.compartment_ocid
  vcn_id                    = oci_core_virtual_network.k8s_vcn.id
  route_table_id            = oci_core_route_table.k8s_pods.id
  dhcp_options_id           = oci_core_virtual_network.k8s_vcn.default_dhcp_options_id
  prohibit_internet_ingress = true
}

resource "oci_core_route_table" "k8s_pods" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "routetable-pods"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }

  route_rules {
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"
    network_entity_id = oci_core_service_gateway.this.id
  }
}

resource "oci_core_security_list" "k8s_pods" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "seclist-pods"

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_api.cidr_block

    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_api.cidr_block

    tcp_options {
      max = "12250"
      min = "12250"
    }
  }

  egress_security_rules {
    protocol    = "1"
    destination = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = local.subnets.k8s_pods.cidr_block

    tcp_options {
      max = "53"
      min = "53"
    }
  }

  egress_security_rules {
    protocol    = "17"
    destination = local.subnets.k8s_pods.cidr_block

    udp_options {
      max = "53"
      min = "53"
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"
  }

  egress_security_rules {
    protocol         = "1"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"

    icmp_options {
      type = 3
      code = 4
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.create_mysql_heatwave ? [1] : []
    content {
      protocol    = "6"
      destination = local.subnets.mysql.cidr_block
      tcp_options {
        max = "3306"
        min = "3306"
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.create_mysql_heatwave ? [1] : []
    content {
      protocol    = "6"
      destination = local.subnets.mysql.cidr_block
      tcp_options {
        max = "33060"
        min = "33060"
      }
    }
  }

  ingress_security_rules {
    protocol = "all"
    source   = local.subnets.k8s_worker_nodes.cidr_block
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_pods.cidr_block
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_api.cidr_block
  }

  egress_security_rules {
    protocol    = "all"
    destination = local.subnets.k8s_worker_nodes.cidr_block
  }
}

resource "oci_core_subnet" "k8s_loadbalancers" {
  cidr_block        = local.subnets.k8s_loadbalancers.cidr_block
  display_name      = "loadbalancers"
  dns_label         = "loadbalancers"
  security_list_ids = [oci_core_security_list.k8s_loadbalancers.id]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.k8s_vcn.id
  route_table_id    = oci_core_route_table.k8s_loadbalancers.id
  dhcp_options_id   = oci_core_virtual_network.k8s_vcn.default_dhcp_options_id
}

resource "oci_core_route_table" "k8s_loadbalancers" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "routetable-serviceloadbalancers"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_security_list" "k8s_loadbalancers" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "seclist-loadbalancers"

  egress_security_rules {
    protocol    = "all"
    destination = local.subnets.k8s_worker_nodes.cidr_block
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }
}

resource "oci_core_subnet" "mysql" {
  count = var.create_mysql_heatwave ? 1 : 0

  cidr_block                = local.subnets.mysql.cidr_block
  display_name              = "mysql"
  dns_label                 = "mysql"
  security_list_ids         = [oci_core_security_list.mysql[0].id]
  compartment_id            = var.compartment_ocid
  vcn_id                    = oci_core_virtual_network.k8s_vcn.id
  route_table_id            = oci_core_route_table.mysql[0].id
  dhcp_options_id           = oci_core_virtual_network.k8s_vcn.default_dhcp_options_id
  prohibit_internet_ingress = true
}

resource "oci_core_route_table" "mysql" {
  count = var.create_mysql_heatwave ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "routetable-mysql"

  route_rules {
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"
    network_entity_id = oci_core_service_gateway.this.id
  }
}

resource "oci_core_security_list" "mysql" {
  count = var.create_mysql_heatwave ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.k8s_vcn.id
  display_name   = "seclist-mysql"

  egress_security_rules {
    protocol         = "6"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"
  }

  egress_security_rules {
    protocol         = "1"
    destination_type = "SERVICE_CIDR_BLOCK"
    destination      = "all-${local.lowercase_region_identifier}-services-in-oracle-services-network"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_worker_nodes.cidr_block

    tcp_options {
      max = "3306"
      min = "3306"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_worker_nodes.cidr_block

    tcp_options {
      max = "33060"
      min = "33060"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_pods.cidr_block

    tcp_options {
      max = "3306"
      min = "3306"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = local.subnets.k8s_pods.cidr_block

    tcp_options {
      max = "33060"
      min = "33060"
    }
  }
}
