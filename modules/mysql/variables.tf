variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}

variable "mysql_subnet_id" {
  description = "The OCID of the MySQL subnet"
  type        = string
  default     = ""
}

variable "admin_username" {
  description = "MySQL database admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "MySQL database admin password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_mysql_heatwave" {
  description = "Whether to create the MySQL HeatWave cluster"
  type        = bool
  default     = false
}
