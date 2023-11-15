<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_sfn_state_machine.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [archive_file.lambda_task](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `any` | n/a | yes |
| <a name="input_base_task_definition"></a> [base\_task\_definition](#input\_base\_task\_definition) | n/a | `any` | n/a | yes |
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | n/a | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `any` | n/a | yes |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | n/a | `any` | n/a | yes |
| <a name="input_migrate_command"></a> [migrate\_command](#input\_migrate\_command) | n/a | `any` | n/a | yes |
| <a name="input_migrate_task_definition"></a> [migrate\_task\_definition](#input\_migrate\_task\_definition) | n/a | `any` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | n/a | `any` | n/a | yes |
| <a name="input_run_command_list"></a> [run\_command\_list](#input\_run\_command\_list) | n/a | `any` | n/a | yes |
| <a name="input_sg_list"></a> [sg\_list](#input\_sg\_list) | n/a | `any` | n/a | yes |
| <a name="input_subnets_list"></a> [subnets\_list](#input\_subnets\_list) | n/a | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `any` | n/a | yes |
| <a name="input_target_container_name"></a> [target\_container\_name](#input\_target\_container\_name) | n/a | `any` | n/a | yes |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | n/a | `any` | n/a | yes |
| <a name="input_wait_seconds"></a> [wait\_seconds](#input\_wait\_seconds) | n/a | `number` | `10` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sfn_arn"></a> [sfn\_arn](#output\_sfn\_arn) | n/a |
<!-- END_TF_DOCS -->