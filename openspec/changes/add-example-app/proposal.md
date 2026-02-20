## Why

The free-tier OKE cluster is fully provisioned but ships with no workloads, making it hard for users to verify the cluster is functioning end-to-end (ingress, DNS, load balancer). An example application gives users a concrete, immediately deployable artifact that exercises the full stack — cluster, ingress, and the optional OCI Load Balancer — right after `terraform apply`.

## What Changes

- Add an `examples/app/` directory containing Kubernetes manifests for a minimal example workload
- The example app is a lightweight HTTP server (nginx-based) deployed as a `Deployment` + `Service` + optional `Ingress`
- The `Ingress` resource wires into the OCI Flexible Load Balancer (already provisioned by the `load-balancer` module) using standard Kubernetes ingress annotations for OCI
- Add a `README.md` inside `examples/app/` with full deploy, verify, and teardown instructions
- Add a top-level section in the root `README.md` linking to the example app guide
- No Terraform changes required; this is a pure Kubernetes manifest addition

## Capabilities

### New Capabilities

- `example-app-deployment`: A self-contained set of Kubernetes manifests (`Deployment`, `Service`, `Ingress`) for an example nginx workload that validates the cluster's ingress and load-balancer path is functional after provisioning

### Modified Capabilities

*(none — no existing spec-level requirements change)*

## Impact

- **New files**: `examples/app/deployment.yaml`, `examples/app/service.yaml`, `examples/app/ingress.yaml`, `examples/app/README.md`
- **Documentation**: Root `README.md` updated with an "Example App" section
- **Runtime**: Requires a running OKE cluster and `kubectl` access (via bastion or VPN). Optionally requires the `load-balancer` module to be enabled (`create_load_balancer = true`) for the `Ingress` to get a public IP
- **No impact** on Terraform state, existing modules, or CI/CD pipelines
