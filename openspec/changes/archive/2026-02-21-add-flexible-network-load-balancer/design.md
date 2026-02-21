## Context

The OCI Always Free tier includes a 10 Mbps Flexible Load Balancer (Layer 7) and a Flexible Network Load Balancer (Layer 4). Currently, the `load-balancer` module provisions the Layer 7 load balancer and configures it for TCP pass-through on ports 80 and 443. While functional, a Layer 4 Network Load Balancer (NLB) is generally the recommended best practice for routing traffic to Kubernetes ingress controllers because it provides lower latency, avoids unnecessary Layer 7 processing overhead, and preserves the client source IP address natively.

## Goals / Non-Goals

**Goals:**
- Introduce new boolean input variables `create_application_load_balancer` and `create_network_load_balancer` to let the user select which load balancers to provision.
- Add `oci_network_load_balancer_network_load_balancer` provisioning support alongside the existing `oci_load_balancer_load_balancer` in the `load-balancer` module.
- Allow both load balancers to be provisioned simultaneously if desired.
- Ensure the Application Load Balancer enforces the 10 Mbps limits (Always Free). The Network Load Balancer does not require bandwidth configuration.
- Ensure existing HTTP (80) and HTTPS (443) traffic is correctly routed to worker nodes for both paths.
- Conditionally output discrete IP addresses for each chosen load balancer.

**Non-Goals:**
- Configuring an ingress controller within the Kubernetes cluster.
- Supporting load balancer shapes beyond the flexible 10 Mbps Always Free tier.

## Decisions

- **Decision: Keep a single module and use conditional logic (`count`) instead of creating separate modules.**
  - **Rationale:** Keeping the logic in the `load-balancer` module prevents duplication of repetitive outputs and keeps the root `main.tf` clean. Users only need to set boolean flags to true or false.
  - **Alternatives Considered:** Extracting two separate modules (`modules/alb` and `modules/nlb`). *Rejected* because they share the same subnet strategy, security configurations, and ultimate goals.

- **Decision: Use independent boolean toggles (`create_application_load_balancer` and `create_network_load_balancer`).**
  - **Rationale:** The OCI Always Free tier permits concurrent provisioning of one flexible ALB and one flexible NLB. Using independent toggles rather than an either/or switch gives users the maximum flexibility to use both resources if needed.

- **Decision: Enforce bandwidth limits only on the Application Load Balancer.**
  - **Rationale:** The OCI `oci_load_balancer_load_balancer` requires explicit `minimum_bandwidth_in_mbps` and `maximum_bandwidth_in_mbps` set to 10 to stay strictly in the Free Tier. The `oci_network_load_balancer_network_load_balancer` does not have bandwidth configurations; it natively scales up to 8 Gbps and is entirely Always Free.

- **Decision: Preserve Client IP.**
  - **Rationale:** The NLB supports `is_preserve_source_destination = true`. This is beneficial for ingress controllers to see the actual client IP for logging and rate limiting.

## Risks / Trade-offs

- **[Risk]** Replacing a load balancer requires destroying the old one and creating a new one. This will result in a new public IP address.
  - **Mitigation:** Document this behavior so users know they will need to update their DNS records. This is acceptable since it's an infrastructure-as-code deployment and typically DNS would be managed separately or via external-dns.
