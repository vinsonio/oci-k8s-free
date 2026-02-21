## ADDED Requirements

### Requirement: Example app manifests exist
The repository SHALL include a set of Kubernetes YAML manifests under `examples/app/` that can be applied to the OKE cluster to deploy a functional HTTP workload.

#### Scenario: Manifests are present
- **WHEN** a user clones the repository
- **THEN** the files `examples/app/00-namespace.yaml`, `examples/app/deployment.yaml`, `examples/app/service.yaml`, and `examples/app/ingress.yaml` SHALL exist

### Requirement: Namespace isolation
The example app SHALL be deployed into a dedicated Kubernetes namespace named `example-app`.

#### Scenario: Namespace created on apply
- **WHEN** the user runs `kubectl apply -f examples/app/`
- **THEN** a namespace named `example-app` SHALL be created if it does not already exist

### Requirement: Deployment runs on ARM nodes
The `Deployment` manifest SHALL use an image compatible with `linux/arm64` (the VM.Standard.A1.Flex architecture used by OKE node pools).

#### Scenario: Pod schedules successfully
- **WHEN** the manifests are applied to a cluster with A1.Flex worker nodes
- **THEN** all Deployment pods SHALL reach `Running` state without `ImagePullBackOff` or architecture mismatch errors

### Requirement: Service exposes the app internally
A `ClusterIP` or `NodePort` `Service` manifest SHALL expose the nginx container on port 80 within the cluster.

#### Scenario: Service endpoints populated
- **WHEN** the Deployment pods are running
- **THEN** `kubectl get endpoints -n example-app` SHALL show at least one ready endpoint

### Requirement: Ingress routes external traffic
An `Ingress` manifest SHALL be provided that wires the Service to the OCI Flexible Load Balancer when the `load-balancer` module is enabled.

#### Scenario: Ingress gets an external IP
- **WHEN** the `load-balancer` Terraform module is enabled and the Ingress is applied
- **THEN** `kubectl get ingress -n example-app` SHALL show a non-empty `ADDRESS` field within a reasonable time (up to 5 minutes)

#### Scenario: HTTP request returns 200
- **WHEN** the Ingress has an external IP assigned
- **THEN** `curl http://<EXTERNAL_IP>` SHALL return an HTTP 200 response with nginx default page content

### Requirement: Port-forward fallback for verification
The README SHALL document a port-forward verification path that works even when the OCI Load Balancer is not enabled.

#### Scenario: Verification without load balancer
- **WHEN** the user follows the port-forward instructions in `examples/app/README.md`
- **THEN** `curl http://localhost:8080` SHALL return an HTTP 200 response from the example app pod

### Requirement: Teardown documented and complete
The `examples/app/README.md` SHALL include teardown instructions that fully remove all example app resources from the cluster.

#### Scenario: Clean teardown
- **WHEN** the user runs the teardown command from the README
- **THEN** the `example-app` namespace and all its resources SHALL be deleted from the cluster

### Requirement: README documents prerequisites and steps
The `examples/app/README.md` SHALL document: prerequisites (running cluster, kubectl access, optional load balancer), deploy steps, verification steps, and teardown steps.

#### Scenario: User can follow README end-to-end
- **WHEN** a user with a running OKE cluster follows the README instructions from start to finish
- **THEN** the example app SHALL be accessible and verifiable without additional external guidance
