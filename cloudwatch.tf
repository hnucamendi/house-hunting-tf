# resource "aws_cloudwatch_log_group" "apigw_main" {
#   name              = "/aws/apigateway/${aws_apigatewayv2_api.main.name}-access-logs"
#   retention_in_days = 7
# }