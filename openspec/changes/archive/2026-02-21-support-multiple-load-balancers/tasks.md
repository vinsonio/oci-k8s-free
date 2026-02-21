## 1. Load Balancer Module Refactoring

- [ ] 1.1 Update `modules/load-balancer/variables.tf` by removing `create_load_balancer` and `load_balancer_type`, and replacing them with `create_network_load_balancer` and `create_application_load_balancer` booleans.
- [ ] 1.2 Refactor `modules/load-balancer/main.tf` to use `count = var.create_network_load_balancer ? 1 : 0` for all NLB-specific resources (NLB, listener, backend set, backend).
- [ ] 1.3 Refactor `modules/load-balancer/main.tf` to use `count = var.create_application_load_balancer ? 1 : 0` for all ALB-specific resources (ALB, listener, backend set, backend).
- [ ] 1.4 Update `modules/load-balancer/outputs.tf` to export `network_load_balancer_ip` and `application_load_balancer_ip` based on the respecitve resources list lengths.

## 2. Root Configuration Updates

- [x] 2.1 Update root `variables.tf` by removing the deprecated `create_load_balancer` and `load_balancer_type` variables, introducing the independent booleans with `false` defaults.
- [x] 2.2 Re-wire `main.tf` to pass the two new booleans into `module "load_balancer"`.
- [x] 2.3 Update root `outputs.tf` to map to the new module outputs.

## 3. Documentation

- [x] 3.1 Update `ALWAYS-FREE-RESOURCES.md` to explicitly warn that provisioning BOTH load balancers concurrently will exceed the free tier limit.
- [x] 3.2 Update `README.md` to reflect the updated variables and the identical cost warning.
- [x] 3.3 Ensure the example app configuration `examples/app/README.md` also points to `create_network_load_balancer = true` instead of the old legacy flag.
- [x] 3.4 Run `terraform fmt` and `terraform validate`.
