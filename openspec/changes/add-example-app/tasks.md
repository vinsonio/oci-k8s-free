## 1. Kubernetes Manifests

- [x] 1.1 Create `examples/app/namespace.yaml` defining the `example-app` namespace
- [x] 1.2 Create `examples/app/deployment.yaml` with a 2-replica nginx Deployment using `nginx:stable-alpine` (ARM-compatible), resource requests/limits, and liveness/readiness probes on port 80
- [x] 1.3 Create `examples/app/service.yaml` with a `ClusterIP` Service exposing port 80 in the `example-app` namespace
- [x] 1.4 Create `examples/app/ingress.yaml` with an `Ingress` resource using `ingressClassName: oci` (or equivalent OCI annotation) routing `/` to the Service, with a comment noting it requires `create_load_balancer = true`

## 2. Documentation

- [x] 2.1 Create `examples/app/README.md` with: prerequisites (running cluster, kubectl configured, optional load balancer), deploy instructions (`kubectl apply -f examples/app/`), verification steps (both Ingress/external IP path and port-forward fallback), and teardown instructions (`kubectl delete namespace example-app`)
- [x] 2.2 Update root `README.md` to include an "Example App" section that links to `examples/app/README.md` and explains the purpose of the example

## 3. Verification

- [x] 3.1 Validate all YAML manifests are syntactically correct (`kubectl apply --dry-run=client -f examples/app/`)
- [x] 3.2 Confirm the `nginx:stable-alpine` image digest supports `linux/arm64` (verify via Docker Hub manifest)
