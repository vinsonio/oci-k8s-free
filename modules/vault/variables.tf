variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "create_vault" {
  description = "Whether to create OCI Vault and Master Encryption Key(s)"
  type        = bool
  default     = false
}

variable "vaults" {
  description = "Map of vaults to create. Key is a logical name, value is the configuration. If empty but create_vault is true, a default vault is created."
  type = map(object({
    name = string
  }))
  default = {
    default = {
      name = "default-vault"
    }
  }
}
