locals {
  bastion_instructions = <<-EOT

OCI Bastion Service created: ${var.create_bastion ? oci_bastion_bastion.k8s_bastion[0].name : "N/A"}

To access Kubernetes API via worker nodes:

1. Get worker node instance OCIDs and private IPs:
   oci ce node-pool get --node-pool-id <POOL_ID> | \
     jq -r '.data.nodes[] | .id + " " + ."private-ip"'

2. Enable the Bastion plugin on the target worker node (one-time per node):
   oci compute instance update --instance-id <NODE_INSTANCE_OCID> \
     --agent-config '{"pluginsConfig": [{"name": "Bastion", "desiredState": "ENABLED"}]}'

   Wait ~2 minutes, then verify the plugin is RUNNING:
   oci compute instance get --instance-id <NODE_INSTANCE_OCID> \
     | jq -r '.data["agent-config"]["plugins-config"][] | select(.name=="Bastion")'

3. Create a managed SSH session to a worker node:
   oci bastion session create-managed-ssh \
     --bastion-id ${var.create_bastion ? oci_bastion_bastion.k8s_bastion[0].id : "BASTION_ID"} \
     --ssh-public-key-file ~/.ssh/id_rsa.pub \
     --target-resource-id <NODE_INSTANCE_OCID> \
     --target-private-ip <NODE_PRIVATE_IP> \
     --target-os-username opc \
     --display-name "k8s-worker-access"

4. Wait for session to become ACTIVE, then get session details:
   SESSION_ID=<from-previous-command>
   oci bastion session get --session-id $SESSION_ID

5. Connect using the SSH command from session details:
   ssh -i ~/.ssh/id_rsa -o ProxyCommand='ssh -i ~/.ssh/id_rsa -W %h:%p -p 22 <session-id>@host.bastion.<region>.oci.oraclecloud.com' opc@<node-ip>

6. Once on worker node, use kubectl:
   kubectl get nodes
   kubectl get pods --all-namespaces

See: https://docs.oracle.com/en-us/iaas/Content/Bastion/Tasks/managingsessions.htm
  EOT
}

output "bastion_id" {
  description = "OCID of the OCI Bastion Service"
  value       = var.create_bastion ? oci_bastion_bastion.k8s_bastion[0].id : null
}

output "bastion_name" {
  description = "Name of the bastion service"
  value       = var.create_bastion ? oci_bastion_bastion.k8s_bastion[0].name : null
}

output "bastion_state" {
  description = "Current state of the bastion service"
  value       = var.create_bastion ? oci_bastion_bastion.k8s_bastion[0].state : null
}

output "usage_instructions" {
  description = "Instructions for creating bastion sessions"
  value       = var.create_bastion ? local.bastion_instructions : ""
}
