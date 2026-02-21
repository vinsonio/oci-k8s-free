## Context

The OCI OKE free-tier cluster is provisioned by Terraform but ships with zero workloads. Users need a reference deployment to validate that networking, ingress, and the optional OCI Load Balancer are wired up correctly end-to-end. This design covers how the example manifests are structured and how they fit the existing architecture without requiring any Terraform changes.

## Goals / Non-Goals

**Goals:**
- Provide ready-to-apply Kubernetes YAML manifests for a minimal nginx-based HTTP app
- Exercise the full ingress path: Pod → Service → Ingress → OCI Flexible Load Balancer
- Work on ARM (VM.Standard.A1.Flex / `linux/arm64`)
- Keep the example entirely additive; no changes to existing Terraform modules
- Document deploy / verify / teardown steps in `examples/app/README.md`

**Non-Goals:**
- Persistent storage, databases, or StatefulSets
- TLS / HTTPS termination (out of scope for free-tier example; documented as future work)
- Helm chart packaging
- Automated CI/CD pipeline for the example app itself

## Decisions

### Decision 1: nginx as the workload image
**Choice**: `nginx:stable-alpine` (multi-arch, includes `linux/arm64`)  
**Rationale**: Zero external dependencies, well-known, available on ARM, and serves HTTP on port 80 out of the box — ideal for verifying ingress reachability.  
**Alternative considered**: A custom Go binary — rejected because it adds a build step and image registry dependency.

### Decision 2: Manifests live in `examples/app/`, not a Terraform module
**Choice**: Plain YAML manifests under `examples/app/`  
**Rationale**: The example is a runtime concern (kubectl apply), not infrastructure-as-code. Keeping it in `examples/` signals clearly that it is optional post-provisioning material rather than part of the Terraform state.  
**Alternative considered**: A Terraform `helm_release` resource — rejected because it introduces Helm/Terraform dependencies and tightly couples the example to the infra lifecycle.

### Decision 3: Ingress uses OCI Native Ingress Controller annotations
**Choice**: `kubernetes.io/ingress.class: oci` annotation pattern (or `ingressClassName: oci`)  
**Rationale**: The `load-balancer` module already provisions an OCI Flexible Load Balancer in the `k8s_loadbalancers` subnet. The OCI Native Ingress Controller (pre-installed on OKE clusters) can wire an `Ingress` resource to it automatically.  
**Alternative considered**: NGINX Ingress Controller — rejected because it requires an additional Deployment and is not pre-installed on OKE.

### Decision 4: Namespace `example-app`
**Choice**: Deploy into a dedicated `example-app` namespace  
**Rationale**: Keeps the example cleanly isolated from system namespaces; easy to teardown with `kubectl delete namespace example-app`.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| OCI Native Ingress Controller may not be enabled on all OKE clusters | README documents both Ingress-based and port-forward verification paths |
| `load-balancer` module is optional — Ingress won't get an external IP if LB is not enabled | README notes the `create_load_balancer = true` prerequisite; also documents ClusterIP + port-forward as a fallback |
| ARM image availability | `nginx:stable-alpine` is a multi-arch official image; confirmed `linux/arm64` support |
| Users may leave example resources running and consume node resources | README includes explicit teardown instructions |

## Migration Plan

1. User runs `terraform apply` with the existing configuration to provision the cluster
2. User configures `kubectl` access (via bastion SSH tunnel or VPN)
3. User applies manifests: `kubectl apply -f examples/app/`
4. User verifies: `curl http://<EXTERNAL_IP>` or `kubectl port-forward`
5. Teardown: `kubectl delete namespace example-app`

No rollback needed — manifests are additive and deletion restores the prior cluster state.

## Open Questions

*(none — all decisions resolved above)*
