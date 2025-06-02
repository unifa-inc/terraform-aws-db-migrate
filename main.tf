provider "archive" {}

resource "aws_sfn_state_machine" "main" {
  # suffix
  name       = format("db-migrate-state-machine-%s-%s-%s", var.project_name, var.app_name, var.environment)
  role_arn   = aws_iam_role.sfn.arn
  definition = <<EOF
{
  "Comment": "For db:migrate state machine",
  "StartAt": "Create Task Definiton creation",
  "States": {
    "Create Task Definiton creation": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.function.arn}",
      "Next":"Wait Task Definiton creation"
    },
    "Wait Task Definiton creation": {
      "Type": "Wait",
      "Seconds": ${var.wait_seconds},
      "Next":"Run Task"
    },
    "Run Task": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${var.cluster_arn}",
        "TaskDefinition": "${local.migrate_task_definition_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "SecurityGroups": ${jsonencode(var.sg_list)},
            "Subnets": ${jsonencode(var.subnets_list)}
          }
        },
        "Overrides": {
          "ContainerOverrides": [
            {
              "Name": "${var.target_container_name}",
              "Command": ${jsonencode(var.run_command_list)}
            }
          ]
        }
      },
      "End": true
    }
  }
}
EOF
  tags       = var.tags
}

resource "aws_iam_role" "sfn" {
  name = format("DbMigrateState%s%s%sRole", local.upper_project_name, title(var.app_name), title(var.environment))

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy" "sfn" {
  role   = aws_iam_role.sfn.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "ecs:StopTask",
        "ecs:DescribeTasks",
        "ecs:TagResource"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "events:PutTargets",
        "events:PutRule",
        "events:DescribeRule"
      ],
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
          "*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role" "lambda" {
  name = format("DbMigrateLambda%s%s%sRole", local.upper_project_name, title(var.app_name), title(var.environment))

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.lambda.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

data "archive_file" "lambda_task" {
  type        = "zip"
  source_dir  = format("%s/lambda/gen_migrate_task", path.module)
  output_path = format("%s/lambda/archive/lambda_function.zip", path.module)
}

resource "aws_lambda_function" "function" {
  function_name = format("GenMigrateTask%s%s%s", var.project_name, var.app_name, var.environment)
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda.arn
  runtime       = "ruby3.2"

  filename         = data.archive_file.lambda_task.output_path
  source_code_hash = data.archive_file.lambda_task.output_base64sha256

  environment {
    variables = {
      AppContainerName      = var.target_container_name
      BaseTaskDefinition    = var.base_task_definition
      ImageTag              = var.image_tag
      MigrateCommand        = var.migrate_command
      MigrateTaskDefinition = var.migrate_task_definition
      MigrateLogGroupName   = var.migrate_log_group_name
    }
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy_attachment.lambda]
}


# logs
resource "aws_cloudwatch_log_group" "lambda" {
  name              = format("/aws/lambda/%s", format("GenMigrateTask%s%s%s", var.project_name, var.app_name, var.environment))
  retention_in_days = 60

  tags = var.tags
}
