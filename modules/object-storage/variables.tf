variable "compartment_ocid" {
  description = "OCID of the compartment in which to create Object Storage buckets"
  type        = string
}

variable "create_object_storage" {
  description = "Whether to create OCI Object Storage buckets. Always Free: 20 GB combined across all storage tiers."
  type        = bool
  default     = false
}

variable "buckets" {
  description = "Map of Object Storage buckets to create. Key is a logical name, value is the bucket configuration."
  type = map(object({
    name         = string
    storage_tier = optional(string, "Standard")
    access_type  = optional(string, "NoPublicAccess")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.buckets : contains(["Standard", "InfrequentAccess", "Archive"], v.storage_tier)
    ])
    error_message = "Each bucket storage_tier must be one of: Standard, InfrequentAccess, Archive."
  }

  validation {
    condition = alltrue([
      for k, v in var.buckets : contains(["NoPublicAccess", "ObjectRead", "ObjectReadWithoutList"], v.access_type)
    ])
    error_message = "Each bucket access_type must be one of: NoPublicAccess, ObjectRead, ObjectReadWithoutList."
  }
}
