# Lambda Functions
resource "aws_lambda_function" "get_projects" {
  function_name = "${local.app_name}-get-projects"
  role          = aws_iam_role.main_role.arn
  architectures = ["x86_64"]
  filename      = "./bootstrap.zip"
  handler       = "bootstrap"
  runtime       = "provided.al2"
}

resource "aws_lambda_function" "post_projects" {
  function_name = "${local.app_name}-post-projects"
  role          = aws_iam_role.main_role.arn
  architectures = ["x86_64"]
  filename      = "./bootstrap.zip"
  handler       = "bootstrap"
  runtime       = "provided.al2"
}

resource "aws_lambda_function" "authorizer" {
  function_name = "${local.app_name}-authorizer"
  role          = aws_iam_role.main_role.arn
  architectures = ["x86_64"]
  filename      = "./bootstrap.zip"
  handler       = "bootstrap"
  runtime       = "provided.al2"

  tracing_config {
    mode = "Active"
  }
}

# IAM Policy Documents
data "aws_iam_policy_document" "lambda_invoke_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      aws_lambda_function.post_projects.arn,
      aws_lambda_function.get_projects.arn,
      aws_lambda_function.authorizer.arn
    ]
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

# IAM Role
resource "aws_iam_role" "main_role" {
  name               = "${local.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.main_lambda_policy_document.json
}

# IAM Role Policies
resource "aws_iam_role_policy" "main_role_policy" {
  name   = "${local.app_name}-role-policy"
  role   = aws_iam_role.main_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          aws_lambda_function.get_projects.arn,
          aws_lambda_function.post_projects.arn,
          aws_lambda_function.authorizer.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
        ],
        Resource = [
          aws_dynamodb_table.projects.arn
        ]
      }
    ]
  })
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "api_gateway_get_projects" {
  statement_id  = "AllowAPIGatewayInvokeProjects"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_projects.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_post_projects" {
  statement_id  = "AllowAPIGatewayInvokeProjects"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_projects.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}