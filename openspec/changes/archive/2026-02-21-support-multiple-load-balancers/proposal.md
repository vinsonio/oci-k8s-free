## Why

Currently, the `load-balancer` module enforces a mutually exclusive choice between provisioning an Application Load Balancer (ALB) or a Network Load Balancer (NLB) using the `load_balancer_type` variable. However, some users require the flexibility to provision *both* load balancers simultaneously to support different types of ingress traffic (e.g., using the ALB for standard HTTP load balancing and the NLB for external traffic routing directly to an internal ingress controller like Traefik). This change removes the mutual exclusivity constraint.

## What Changes

- **BREAKING**: Remove the `create_load_balancer` (bool) and `load_balancer_type` (string) variables from the root `variables.tf` and the `load-balancer` module.
- Introduce `create_network_load_balancer` (bool, default `false`) and `create_application_load_balancer` (bool, default `false`).
- Update the `load-balancer` module to leverage these two new boolean variables to independently provision the ALB and NLB resources using Terraform `count` conditionals.
- Update the root `outputs.tf` to independently output the IP addresses of the active load balancers (e.g., `application_load_balancer_ip` and `network_load_balancer_ip`).
- Update documentation to explicitly warn users that provisioning *both* an ALB and an NLB will exceed the OCI Always Free limits (which restrict users to 1 ALB *OR* 1 NLB), meaning concurrent usage will incur standard OCI unmetered billing costs.

## Capabilities

### New Capabilities
- `multiple-load-balancers`: The configuration logic allowing both Layer 4 (Network) and Layer 7 (Application) load balancers to be provisioned and operated simultaneously within the same OKE cluster environment.

### Modified Capabilities

## Impact

- **Affected code**: Root `variables.tf`, `main.tf`, `outputs.tf`, and the internal files of `modules/load-balancer/`.
- **Infrastructure**: Users with existing clusters who upgrade and apply these new variables will trigger a recreation or state-move of their load balancers depending on how they map the new variables.
- **Cost Warning**: The ability to deploy both breaks the strict $0/month barrier if a user intentionally toggles both to `true`. Clear documentation in `ALWAYS-FREE-RESOURCES.md` and `README.md` is required.
