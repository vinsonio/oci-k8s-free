variable "compartment_ocid" {
  description = "OCID of the compartment where secrets will be created"
  type        = string
}

variable "create_vault_secrets" {
  description = "Whether to provision OCI Vault Secrets"
  type        = bool
  default     = false
}

variable "vault_ids" {
  description = "Map of vault logical names to their OCIDs. Supplied by the root module from the vault module's output."
  type        = map(string)
  default     = {}
}

variable "key_ids" {
  description = "Map of vault logical names to their Master Encryption Key OCIDs. Supplied by the root module from the vault module's output."
  type        = map(string)
  default     = {}
}

variable "vault_secrets" {
  description = "Map of vaults to their secrets. Key is vault logical name. Value is a map of secrets (key is secret logical name)."
  type = map(map(object({
    name           = string
    secret_content = string
  })))
  default = {}
}


