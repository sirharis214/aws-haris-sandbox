variable "project_tags" {
  type        = map(string)
  description = "Incoming project tags to be merged with local.module_tags"
}

variable "assume_roles" {
  type        = map(any)
  description = "tf_management role and any other roles cicd is allowed/needs to assume"
}

variable "state_management_policy_arn" {
  type        = string
  description = "The IAM state_management_assume_role_policy to allow cicd to also interact with terraform states bucket"
}

variable "artifacts_bucket" {
  type = object({
    name = string
    arn  = string
  })
  description = "artifacts bucket name and ARN, used when creating iam permissions to allow cicd to put and get artifacts from it"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN used to encrypt artifacts bucket"
}
