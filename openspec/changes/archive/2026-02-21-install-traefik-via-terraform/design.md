## Context

The current `free-oci-k8s` project provisions a Kubernetes cluster and an OCI Free Tier Load Balancer using Terraform. However, the actual ingress controller (Traefik) that makes the Load Balancer functional for HTTP/HTTPS traffic is installed manually via a bash script (`scripts/install-traefik.sh`). 

This script uses Helm to deploy Traefik as a `LoadBalancer` service type. This tells the OCI Cloud Controller Manager to provision *another* OCI Load Balancer, which can conflict with the one we already provisioned via Terraform and potentially exceed the Always Free quota.

## Goals / Non-Goals

**Goals:**
- Manage the Traefik Ingress Controller lifecycle directly within Terraform.
- Configure Traefik to deploy as a `NodePort` service type instead of `LoadBalancer`.
- Bind Traefik to the specific HTTP (`30080`) and HTTPS (`30443`) NodePorts configured for the Terraform-managed OCI Network Load Balancer.
- Authenticate the Terraform `helm` provider automatically using the `oci_containerengine_cluster_kube_config` data source.

**Non-Goals:**
- Modifying the `examples/app/` Kubernetes Deployment or Ingress manifests.
- Managing SSL/TLS certificates via Terraform (that remains an exercise for `cert-manager` inside the cluster).

## Decisions

- **Decision: Use `helm_release` via a new Terraform module (`modules/ingress-controller`).**
  - **Rationale:** Encapsulating the Helm release in a module allows it to be toggled easily via a variable (e.g., `install_ingress_controller = true`) and keeps the root `main.tf` clean.

- **Decision: Configure Traefik as `ServiceType = NodePort`.**
  - **Rationale:** We are already explicitly provisioning an Always-Free Network Load Balancer via Terraform. Traefik must bind to static `NodePort`s so the NLB can route traffic to it directly, bypassing the Cloud Controller Manager's automated LB provisioning.

- **Decision: Explicitly set Traefik HTTP and HTTPS NodePorts.**
  - **Rationale:** We need to guarantee that the ports Traefik listens on match the `lb_backend_port` (`30080`) and `lb_backend_port_https` (`30443`) variables defined in the `load-balancer` module. This requires overriding the Traefik Helm chart values.

- **Decision: Rely on `oci_containerengine_cluster_kube_config` + `oci` exec plugin for Helm authentication.**
  - **Rationale:** This is the standard HashiCorp-recommended way to authenticate the Terraform `helm` provider against an OKE cluster. It uses the `oci` CLI to generate short-lived tokens seamlessly.

## Risks / Trade-offs

- **[Risk] Terraform execution timeout on Private APIs:** If `kubernetes_api_public_enabled = false`, Terraform running on a local machine without VPN access will time out connecting to the Kubernetes API to install the Helm chart.
  - **Mitigation:** Add clear documentation. If the API is private, users must either run `terraform apply` from a machine with access (Bastion, VPN) or use OCI Resource Manager within the VCN.

- **[Risk] OCI CLI dependency:** The Helm provider configuration requires the `oci` CLI to execute the token generation.
  - **Mitigation:** The active prerequisites already require the OCI CLI for fetching the standard user kubeconfig, meaning this introduces no true new external dependencies.
