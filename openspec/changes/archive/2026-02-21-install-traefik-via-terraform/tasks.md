## 1. Terraform Module Creation

- [x] 1.1 Create `modules/ingress-controller/variables.tf` with necessary inputs (cluster config, nodeports).
- [x] 1.2 Create `modules/ingress-controller/main.tf` using the `helm_release` resource to deploy the `traefik/traefik` chart.
- [x] 1.3 Configure Traefik Helm values inline to use `type=NodePort` and explicitly set `ports.web.nodePort` and `ports.websecure.nodePort`.

## 2. Root Configuration Integration

- [x] 2.1 Add an `install_ingress_controller` boolean variable to root `variables.tf` (default: false to avoid breaking existing setups).
- [x] 2.2 Define the `helm` provider in root `providers.tf` or `main.tf` using the `oci_containerengine_cluster_kube_config` data source for authentication via the `oci` CLI.
- [x] 2.3 Instantiate the `ingress-controller` module in `main.tf`, passing the cluster identifiers and `lb_backend_port`s.

## 3. Cleanup and Documentation

- [x] 3.1 Delete `scripts/install-traefik.sh` as it is now obsolete.
- [x] 3.2 Update `examples/app/README.md` to reflect that the Ingress controller is now provisioned automatically via Terraform.
- [x] 3.3 Run `terraform fmt` and `terraform validate` to ensure codebase integrity.
