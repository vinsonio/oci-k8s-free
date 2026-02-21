## Why

Currently, the Traefik Ingress Controller is installed using a manual bash script (`scripts/install-traefik.sh`). Moving this installation into Terraform allows the entire foundation, from the Kubernetes cluster up to the core ingress controller, to be managed via a single declarative infrastructure-as-code workflow. This ensures better state management, reproducibility, and allows us to easily wire up the new OCI Network Load Balancer ports.

## What Changes

- Add a new Terraform module (e.g., `modules/traefik`) that uses the Terraform `helm` provider to install the `traefik/traefik` chart.
- Configure Traefik as a `NodePort` service listening on the specific `lb_backend_port` (30080) and `lb_backend_port_https` (30443) defined for the OCI Network Load Balancer.
- Authenticate the `helm` provider automatically using the cluster's kubeconfig data source.
- Remove the deprecated `scripts/install-traefik.sh` script.
- Update `examples/app/README.md` to reflect the new automated installation process.

## Capabilities

### New Capabilities
- `traefik-ingress`: Automated deployment of the Traefik Ingress Controller via Terraform and Helm, configured to integrate seamlessly with the OCI free-tier network load balancer.

### Modified Capabilities

## Impact

- **Affected code**: Addition of a new module in `modules/`, updates to the root `main.tf` and `variables.tf`, and modifications to example documentation.
- **Dependencies**: Introduces the `hashicorp/helm` provider to the Terraform state.
- **System limitation**: If the cluster API is made private (`kubernetes_api_public_enabled = false`), Terraform will not be able to connect to the cluster to install Helm charts directly from an external machine without a VPN. This limitation must be documented.
