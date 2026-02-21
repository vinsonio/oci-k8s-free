## ADDED Requirements

### Requirement: Independent ALB Provisioning
The system SHALL provide a `create_application_load_balancer` boolean variable that controls the creation of an OCI Application Load Balancer independently of any other load balancer type.

#### Scenario: ALB created when explicitly requested
- **WHEN** `create_application_load_balancer = true`
- **THEN** an Application Load Balancer and its associated listeners and backend sets SHALL be provisioned

### Requirement: Independent NLB Provisioning
The system SHALL provide a `create_network_load_balancer` boolean variable that controls the creation of an OCI Network Load Balancer independently of any other load balancer type.

#### Scenario: NLB created when explicitly requested
- **WHEN** `create_network_load_balancer = true`
- **THEN** a Network Load Balancer and its associated listeners and backend sets SHALL be provisioned

### Requirement: Concurrent Load Balancer Provisioning
The load balancer module SHALL permit the simultaneous provisioning of both an Application Load Balancer and a Network Load Balancer when both respective flags are set.

#### Scenario: Both load balancers are provisioned
- **WHEN** `create_application_load_balancer = true` AND `create_network_load_balancer = true`
- **THEN** Terraform SHALL apply successfully, provisioning both the ALB and NLB concurrently connected to the same worker node backend IPs

### Requirement: Distinct Output Verification
The Terraform variables SHALL output the public IP addresses for both types of load balancers using distinct output variable names to avoid collision.

#### Scenario: Output names are unambiguous
- **WHEN** `terraform output` is queried
- **THEN** the outputs SHALL display `application_load_balancer_ip` and `network_load_balancer_ip` based on whichever resources are provisioned

## REMOVED Requirements

### Requirement: Mutual Exclusivity
**Reason**: Replaced by independent boolean toggles to support advanced ingress setups
**Migration**: Change `create_load_balancer = true` + `load_balancer_type = "network"` to `create_network_load_balancer = true`. Change `create_load_balancer = true` + `load_balancer_type = "application"` to `create_application_load_balancer = true`.
