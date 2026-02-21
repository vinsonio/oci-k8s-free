# Example App — nginx on OKE

A minimal nginx workload to verify your OCI OKE cluster is functioning end-to-end: scheduling, networking, and ingress.

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Running OKE cluster | Provisioned via `terraform apply` in the repo root |
| Load Balancer | Set `create_network_load_balancer = true` and `install_ingress_controller = true` in `terraform.tfvars` and apply for external IP via `Ingress` |

---

## Deploy

```bash
kubectl apply -f examples/app/
```

This creates:
- `Namespace` — `example-app` (`00-namespace.yaml` — applied first to avoid ordering issues)
- `Deployment` — 2 replicas of `nginx:stable-alpine` (ARM/A1.Flex compatible)
- `Service` — `ClusterIP` on port 80
- `Ingress` — routes `example.app` via the Traefik Ingress Controller

Wait for pods to become ready:

```bash
kubectl rollout status deployment/example-app -n example-app
# Deployment "example-app" successfully rolled out
```

---

## Verify

### Option A: External IP via Load Balancer

```bash
# If using the Network Load Balancer, the external IP is provisioned strictly by Terraform.
# Get the NLB IP from the terraform outputs:
# cd ../../ && terraform output -raw network_load_balancer_ip
EXTERNAL_IP="<your-nlb-ip>"

# Test HTTP access directly
curl -H "Host: example.app" http://$EXTERNAL_IP
# Expected: HTTP 200 with nginx welcome page
```

### Option B: Port-forward (no Load Balancer required)

```bash
# Forward local port 8080 to the example-app service
kubectl port-forward svc/example-app 8080:80 -n example-app &

# Test
curl http://localhost:8080
# Expected: HTTP 200 with nginx welcome page

# Stop port-forward
kill %1
```

---

## Teardown

Remove all example app resources in one command:

```bash
kubectl delete namespace example-app
```

This deletes the namespace and everything inside it (Deployment, Service, Ingress, pods).

---

## Notes

- **ARM compatibility**: `docker.io/library/nginx:stable-alpine` is a multi-arch image with `linux/arm64` support, required for the `VM.Standard.A1.Flex` nodes used by this cluster.
- **Fully-qualified image names required**: OKE nodes run Oracle Linux 9, which enforces `short-name-mode = enforcing` in the container runtime (podman/crio). Unqualified names like `nginx:stable-alpine` will fail with `ImageInspectError`. Always prefix with `docker.io/library/` (official images) or the full registry hostname for other images.
- **TLS**: Not configured in this example. To add HTTPS, enable cert-manager and annotate the `Ingress` with your certificate issuer.
- **Ingress class**: The `Ingress` uses `ingressClassName: traefik` targeting the Traefik Ingress Controller. If your cluster uses a different ingress controller (such as the native OCI ingress: `oci`), update `spec.ingressClassName` accordingly.
