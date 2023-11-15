locals {
  split_project_name                   = split("-", var.project_name)
  upper_project_name                   = join("", [for value in local.split_project_name : title(value)])
  task_definition_arn_without_revision = regex("[^/]*[^:]*", var.task_definition_arn)
  migrate_task_definition_arn          = format("%s/%s", regex("^[^/]+", local.task_definition_arn_without_revision), var.migrate_task_definition)
}

variable app_name {}
variable cluster_arn {}
variable environment {}
variable project_name {}
variable run_command_list {}
variable sg_list {}
variable subnets_list {}
variable tags {}
variable target_container_name {}
variable task_definition_arn {}
variable wait_seconds {
  default = 10
}

variable base_task_definition {}
variable image_tag {}
variable migrate_command {}
variable migrate_task_definition {}
