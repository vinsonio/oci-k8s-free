## ADDED Requirements

### Requirement: Traefik Installation via Terraform
The system SHALL deploy the Traefik Ingress Controller through a Terraform `helm_release` integrated directly into the infrastructure provisioning lifecycle, replacing manual bash scripts.

#### Scenario: Cluster creation includes ingress
- **WHEN** a user provisions the OKE cluster with `install_ingress_controller = true` (or equivalent variable)
- **THEN** Terraform automatically installs the Traefik helm chart into the `traefik` namespace along with the rest of the infrastructure.

### Requirement: NodePort Configuration for OCI NLB
The Traefik service SHALL be configured as a `NodePort` service type and MUST explicitly bind to the configured HTTP and HTTPS backend NodePorts (e.g., 30080 and 30443) that match the OCI Network Load Balancer configuration.

#### Scenario: Ingress receives external traffic
- **WHEN** the OCI Network Load Balancer forwards external traffic to a worker node's `backend_port` or `backend_port_https`
- **THEN** the traffic is successfully routed directly to the Traefik ingress controller pod.

### Requirement: Automated Helm Authentication
The Terraform `helm` provider SHALL authenticate to the Kubernetes cluster automatically using the OCI cluster kubeconfig data source, without requiring manual or static token injection.

#### Scenario: Terraform applies Helm chart
- **WHEN** Terraform reaches the `helm_release` resource during `terraform apply`
- **THEN** it generates a short-lived execution token via the `oci` CLI to authenticate with the Kubernetes API successfully.
