variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository (MUTABLE or IMMUTABLE)."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository (AES256 or KMS)."
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "KMS key ARN when encryption_type is KMS."
  type        = string
  default     = null
}

variable "force_delete" {
  description = "Delete repository even if it contains images."
  type        = bool
  default     = false
}

variable "lifecycle_policy" {
  description = "Optional JSON lifecycle policy document."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the ECR repository."
  type        = map(string)
  default     = {}
}
