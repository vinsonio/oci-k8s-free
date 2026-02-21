## Why

The current OCI Free Tier Kubernetes setup utilizes an Application Load Balancer (`oci_load_balancer_load_balancer`), which performs TCP pass-through for HTTPS ingress but operates at Layer 7. OCI also provides an Always Free Layer 4 Flexible Network Load Balancer (`oci_network_load_balancer_network_load_balancer`). Integrating this NLB is generally preferred for Kubernetes ingress controllers (like Traefik or NGINX) because it provides lower latency, preserves client IP addresses inherently, and is optimized for high-throughput TCP/UDP traffic.

## What Changes

- Add new root variables `create_application_load_balancer` and `create_network_load_balancer` to toggle each load balancer type independently.
- Update the `load-balancer` module to conditionally provision the `oci_load_balancer_load_balancer` (L7), the `oci_network_load_balancer_network_load_balancer` (L4), or both concurrently.
- Ensure the Application Load Balancer option enforces the 10 Mbps Always Free tier limits (the Network Load Balancer scales elastically and has no bandwidth configuration).
- Maintain the existing security posture (inbound 80/443 from internet to worker nodes).

## Capabilities

### New Capabilities

- `network-load-balancer`: Provisions an OCI Always Free Flexible Network Load Balancer for Kubernetes ingress traffic.
- `parallel-load-balancers`: Allows simultaneous provisioning of both a Layer 7 Application Load Balancer and a Layer 4 Network Load Balancer within the Always Free tier.

### Modified Capabilities


## Impact

- **`variables.tf` (Root & Module)**: New boolean variables allow users to toggle each ingress LB type independently.
- **`modules/load-balancer`**: Internal resources will use `count` logic to conditionally create L7 and/or L4 load balancer components.
- **`outputs.tf` (Root & Module)**: Logic must be updated to conditionally output discrete IP addresses for each load balancer that was provisioned.
