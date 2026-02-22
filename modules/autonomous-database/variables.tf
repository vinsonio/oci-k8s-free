variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "adb_subnet_id" {
  description = "The OCID of the autonomous database subnet"
  type        = string
  default     = ""
}

variable "admin_password" {
  description = "Admin password for the Autonomous Database"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_name" {
  description = "Unique database name (alphanumeric, 14 chars max)"
  type        = string
  default     = "appdb"
}

variable "display_name" {
  description = "Display name for the Autonomous Database"
  type        = string
  default     = "AlwaysFreeATP"
}

variable "create_autonomous_database" {
  description = "Whether to create the Always Free ATP Autonomous Database"
  type        = bool
  default     = false
}
