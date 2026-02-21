## Context

Currently, the `load-balancer` module forces users to choose between provisioning an Application Load Balancer or a Network Load Balancer using a boolean flag (`create_load_balancer`) and a string enum (`load_balancer_type = "network" | "application"`). This design prevents users from deploying both simultaneously, which heavily restricts advanced ingress architectures where both Layer 4 and Layer 7 entrypoints are desired.

## Goals / Non-Goals

**Goals:**
- Decouple the provisioning logic for the Application Load Balancer from the Network Load Balancer.
- Allow users to deploy both load balancers concurrently.
- Maintain the static and predictable Always Free tier limits (even if deploying both exceeds it, we must document this clearly).

**Non-Goals:**
- Changing subnet assignments (both load balancers will continue to reside in the `k8s_loadbalancers` subnet).
- Changing backend mapping (both load balancers will continue to route to the worker node pool IPs).
- Providing complex routing rules within the load balancers via Terraform.

## Decisions

- **Decision 1: Introduce independent boolean feature flags.**
  - **Choice**: Replace `create_load_balancer` and `load_balancer_type` with `create_network_load_balancer` and `create_application_load_balancer` (both defaulting to `false`).
  - **Rationale**: This is the most Terraform-idiomatic way to control resource provisioning using `count` meta-arguments. It offers maximum flexibility without introducing complex data structures.
  - **Alternative considered**: Changing `load_balancer_type` to accept a list of strings (e.g., `["network", "application"]`). *Rejected* because mapping resources based on lists in Terraform is arguably more brittle than independent feature flags.

- **Decision 2: Remove mutual exclusivity constraints.**
  - **Choice**: Eliminate the `if network else application` logical branches in the module. Instead, resources specific to an ALB use the `create_application_load_balancer` flag, and resources specific to an NLB use the `create_network_load_balancer` flag independently.
  - **Rationale**: Terraform resource definitions should reflect the architecture correctly. The ALB and NLB share virtually zero identical OCI resource blocks, so branching them independently is safest.

## Risks / Trade-offs

- **[Risk] Always Free Quota Excedence**: Deploying *both* load balancers simultaneously violates the OCI Always Free constraints (which permit 1 ALB *or* 1 NLB).
  - **Mitigation**: Update `ALWAYS-FREE-RESOURCES.md` and repository `README.md` to feature prominent warnings detailing that enabling both flags will incur standard OCI unmetered billing costs for the second load balancer.

## Migration Plan

1. The change introduces a BREAKING change to root `variables.tf`.
2. Existing users must migrate from `create_load_balancer = true` + `load_balancer_type = "network"` to simply `create_network_load_balancer = true`.
3. If users fail to migrate their `terraform.tfvars`, Terraform will throw validation errors about undeclared variables when running `terraform plan`.
4. No automated state mv commands are strictly necessary if users recreate the load balancer, but if they want to avoid a public IP reassignment, they will need to rewrite their state, which is out of scope for general users since this is an open-source template.
