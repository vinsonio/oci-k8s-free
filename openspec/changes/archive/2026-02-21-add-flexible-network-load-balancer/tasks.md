## 1. Load Balancer Module Updates

- [x] 1.1 Add `create_application_load_balancer` and `create_network_load_balancer` variables to `modules/load-balancer/variables.tf` and root `variables.tf`.
- [x] 1.2 Update existing `oci_load_balancer_*` resources in `modules/load-balancer/main.tf` to use `count = var.create_application_load_balancer ? 1 : 0`.
- [x] 1.3 Add `oci_network_load_balancer_network_load_balancer` to `modules/load-balancer/main.tf` using `count = var.create_network_load_balancer ? 1 : 0`.
- [x] 1.4 Add corresponding `oci_network_load_balancer_backend_set`, `oci_network_load_balancer_backend`, and `oci_network_load_balancer_listener` (HTTP/HTTPS) resources with the same `count` condition.

## 2. Module Interfaces

- [x] 2.1 Pass boolean toggles from root `main.tf` to the `load_balancer` module block.
- [x] 2.2 Update `modules/load-balancer/outputs.tf` to output discrete IP addresses (`application_load_balancer_ip` and `network_load_balancer_ip`).
- [x] 2.3 Ensure the root `outputs.tf` accurately reflects the IP addresses of the provisioned load balancers.

## 3. Verification

- [x] 3.1 Run `terraform fmt` and `terraform validate` to ensure syntax is correct
- [x] 3.2 Run `tflint` to verify OCI provider best practices
