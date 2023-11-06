variable "project_tags" {
  type        = map(string)
  description = "Incoming project tags to be merged with local.module_tags"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN used to encrypt artifacts bucket"
}

variable "state_management_policy_arn" {
  type        = string
  description = "The IAM state_management_assume_role_policy to allow cicd to also interact with terraform states bucket"
}
