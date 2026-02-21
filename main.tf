terraform {
  required_version = ">= 1.0"
}

# Networking infrastructure (VCN, subnets, security lists, gateways)
module "networking" {
  source = "./modules/networking"

  compartment_ocid              = var.compartment_ocid
  region_identifier             = var.region_identifier
  kubernetes_api_public_enabled = var.kubernetes_api_public_enabled
  allowed_k8s_api_cidrs         = var.allowed_k8s_api_cidrs
}

# Kubernetes cluster and node pool
module "kubernetes" {
  source = "./modules/kubernetes"

  compartment_ocid              = var.compartment_ocid
  kubernetes_version            = var.kubernetes_version
  cluster_name                  = var.cluster_name
  image_id                      = var.image_id
  kubernetes_api_public_enabled = var.kubernetes_api_public_enabled
  node_pool_size                = var.node_pool_size

  vcn_id                      = module.networking.vcn_id
  k8s_api_subnet_id           = module.networking.k8s_api_subnet_id
  k8s_worker_nodes_subnet_id  = module.networking.k8s_worker_nodes_subnet_id
  k8s_pods_subnet_id          = module.networking.k8s_pods_subnet_id
  k8s_loadbalancers_subnet_id = module.networking.k8s_loadbalancers_subnet_id
}

# Optional OCI Bastion Service for private API access
# Enable with create_bastion = true when kubernetes_api_public_enabled = false
module "bastion" {
  source = "./modules/bastion"

  compartment_ocid       = var.compartment_ocid
  cluster_name           = var.cluster_name
  create_bastion         = var.create_bastion
  target_subnet_id       = module.networking.k8s_worker_nodes_subnet_id # Bastion connects to worker nodes
  client_cidr_allow_list = var.bastion_client_cidr_allow_list
}

# Optional Site-to-Site VPN for private API access
# Enable with create_vpn = true when kubernetes_api_public_enabled = false
module "vpn" {
  source = "./modules/vpn"

  compartment_ocid      = var.compartment_ocid
  cluster_name          = var.cluster_name
  create_vpn            = var.create_vpn
  vcn_id                = module.networking.vcn_id
  k8s_api_subnet_cidr   = module.networking.k8s_api_subnet_cidr
  cpe_ip_address        = var.cpe_ip_address
  customer_network_cidr = var.customer_network_cidr
}

# Observability (logging, VCN flow logs)
module "observability" {
  source = "./modules/observability"

  compartment_ocid           = var.compartment_ocid
  cluster_name               = var.cluster_name
  k8s_api_subnet_id          = module.networking.k8s_api_subnet_id
  k8s_worker_nodes_subnet_id = module.networking.k8s_worker_nodes_subnet_id
  vcn_id                     = module.networking.vcn_id
}

# Optional OCI load balancers for public Kubernetes ingress
# Always Free: 1 flexible NLB and 1 flexible ALB per tenancy
# Enable with create_network_load_balancer = true or create_application_load_balancer = true
module "load_balancer" {
  source = "./modules/load-balancer"

  compartment_ocid                 = var.compartment_ocid
  cluster_name                     = var.cluster_name
  create_network_load_balancer     = var.create_network_load_balancer
  create_application_load_balancer = var.create_application_load_balancer
  lb_subnet_id                     = module.networking.k8s_loadbalancers_subnet_id
  backend_node_ips                 = module.kubernetes.node_private_ips
  backend_port                     = var.lb_backend_port
  backend_port_https               = var.lb_backend_port_https
}

# Optional Traefik Ingress Controller
# Enable with install_ingress_controller = true
module "ingress_controller" {
  source = "./modules/ingress-controller"

  cluster_id                 = module.kubernetes.cluster_id
  install_ingress_controller = var.install_ingress_controller
  backend_port               = var.lb_backend_port
  backend_port_https         = var.lb_backend_port_https

  depends_on = [
    module.kubernetes,
    module.networking
  ]
}
