locals {
  module_tags = {
    module_name = join("/", compact([
      lookup(var.project_tags, "module_name", null),
      local.module_name
    ]))
  }
  tags = merge(var.project_tags, local.module_tags)
}