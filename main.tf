# Pulls the information from current account and region deploying to
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
# Package the lambda code
data "archive_file" "zipit" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

# Default role policy for lambda to allow it to send logs to CloudWatch
resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.function_name}_policy"
  path        = "/"
  description = "lambda permission policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}:*"
            ]
        }
    ]
}
EOF
}

# Role creation for Lambda allowing the lambda serivce to assume the attached permissions
resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.function_name}_role"
  managed_policy_arns = [aws_iam_policy.lambda_policy.arn]  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Creation of the lambda function
resource "aws_lambda_function" "eb_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.zipit.output_base64sha256

  runtime = "python3.9"

}

# Creation of the Event rule
resource "aws_cloudwatch_event_rule" "cron_job" {
  count = length(var.cron)
  name        = "${var.function_name}_rule_${count.index}"
  description = "Cron Job to Trigger Lambda"

  schedule_expression = "cron(${var.cron[count.index]})"
}

# Creating the lambda target for the rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  count = length(var.cron)
  rule      = aws_cloudwatch_event_rule.cron_job[count.index].name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.eb_lambda.arn
}

# Permissions to allow cloudwatch to invoke the lambda 
resource "aws_lambda_permission" "allow_cloudwatch" {
  count = length(var.cron)
  statement_id  = "${var.function_name}_rule_${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eb_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_job[count.index].arn
}