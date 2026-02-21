## ADDED Requirements

### Requirement: Provision Configured Load Balancers
The load-balancer module MUST provision an `oci_load_balancer_load_balancer` (Layer 7), an `oci_network_load_balancer_network_load_balancer` (Layer 4), or both based on the provided configuration variables.

#### Scenario: Provision Application Load Balancer
- **WHEN** the `create_application_load_balancer` variable is set to `true`
- **THEN** the module MUST provision an Always Free Tier compliant Application Load Balancer.

#### Scenario: Provision Network Load Balancer
- **WHEN** the `create_network_load_balancer` variable is set to `true`
- **THEN** the module MUST provision an Always Free Tier compliant Network Load Balancer.

### Requirement: Enforce Always Free Constraints for Application Load Balancers
If an Application Load Balancer is selected, it MUST enforce Always Free bandwidth limits. The Network Load Balancer does not require bandwidth configuration and scales elastically.

#### Scenario: Verify Always Free constraints on ALB
- **WHEN** an Application Load Balancer is created
- **THEN** it MUST be configured with both minimum and maximum bandwidth set to 10 Mbps to ensure it qualifies for the Always Free tier.

### Requirement: Route HTTP/HTTPS traffic to worker nodes
The provisioned load balancer MUST listen on TCP ports 80 and 443 and forward traffic to the worker nodes.

#### Scenario: Verify HTTP/HTTPS listener
- **WHEN** a client sends traffic on TCP port 80 or 443
- **THEN** the load balancer MUST route the traffic to the corresponding backend port on the worker nodes.

### Requirement: Preserve Client Source IP (Network LB Only)
If a Network Load Balancer is provisioned, it SHOULD correctly preserve the original client IP address.

#### Scenario: Verify source IP preservation
- **WHEN** traffic is forwarded to a backend node via a Network Load Balancer
- **THEN** the `is_preserve_source_destination` attribute MUST be enabled on the network load balancer.
