variable "project_tags" {
  type        = map(string)
  description = "Incoming project tags to be merged with local.module_tags"
  default = {
    maintainer = "haris-poweruser"
  }
}