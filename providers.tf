provider "oci" {
  region = var.region
}

# Fetch the kubeconfig from the provisioned cluster
data "oci_containerengine_cluster_kube_config" "kubeconfig" {
  cluster_id = module.kubernetes.cluster_id
}

provider "helm" {
  kubernetes {
    host                   = try(yamldecode(data.oci_containerengine_cluster_kube_config.kubeconfig.content)["clusters"][0]["cluster"]["server"], "")
    cluster_ca_certificate = try(base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.kubeconfig.content)["clusters"][0]["cluster"]["certificate-authority-data"]), "")

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "oci"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", module.kubernetes.cluster_id, "--region", var.region]
    }
  }
}
