resource "aws_lambda_function" "criteria" {
  function_name = "${local.app_name}-criteria"
  role          = aws_iam_role.main_role.arn
  architectures = ["arm64"]
  filename      = "./bootstrap.zip"
  handler       = "main.HandleRequest"
  runtime       = "provided.al2"
}

resource "aws_lambda_function" "ratings" {
  function_name = "${local.app_name}-ratings"
  role          = aws_iam_role.main_role.arn
  architectures = ["arm64"]
  filename      = "./bootstrap.zip"
  handler       = "main.HandleRequest"
  runtime       = "provided.al2"
}

resource "aws_lambda_function" "projects" {
  function_name = "${local.app_name}-projects"
  role          = aws_iam_role.main_role.arn
  architectures = ["arm64"]
  filename      = "./bootstrap.zip"
  handler       = "main.HandleRequest"
  runtime       = "provided.al2"
}

resource "aws_lambda_function" "authorizer" {
  function_name = "${local.app_name}-authorizer"
  role          = aws_iam_role.main_role.arn
  architectures = ["arm64"]
  filename      = "./bootstrap.zip"
  handler       = "main.HandleRequest"
  runtime       = "provided.al2"

  tracing_config {
    mode = "Active"
  }
}

data "aws_iam_policy_document" "main_lambda_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com", "scheduler.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudwatch_logs_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "main_role" {
  name               = "${local.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.main_lambda_policy_document.json
}

resource "aws_iam_role_policy" "main_role_policy" {
  name   = "${local.app_name}-role-policy"
  role   = aws_iam_role.main_role.id
  policy = data.aws_iam_policy_document.cloudwatch_logs_policy.json
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}