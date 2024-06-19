resource "aws_apigatewayv2_api" "main" {
 name          = local.app_name
 protocol_type = "HTTP"

 cors_configuration {
   allow_origins = ["http://localhost:5173/", "https://house-hunting.hnucamendi.me/"]
   allow_headers = ["Authorization"]
   allow_methods = ["GET", "POST", "PUT"]
 }
}

resource "aws_apigatewayv2_route" "post_criteria" {
 api_id          = aws_apigatewayv2_api.main.id
 route_key       = "POST /criteria"
 target          = "integrations/${aws_apigatewayv2_integration.criteria.id}"
 authorizer_id   = aws_apigatewayv2_authorizer.main_authorizer.id
 authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "post_ratings" {
 api_id          = aws_apigatewayv2_api.main.id
 route_key       = "POST /ratings"
 target          = "integrations/${aws_apigatewayv2_integration.ratings.id}"
 authorizer_id   = aws_apigatewayv2_authorizer.main_authorizer.id
 authorization_type = "CUSTOM"
}
resource "aws_apigatewayv2_route" "post_projects" {
 api_id          = aws_apigatewayv2_api.main.id
 route_key       = "POST /projects"
 target          = "integrations/${aws_apigatewayv2_integration.ratings.id}"
 authorizer_id   = aws_apigatewayv2_authorizer.main_authorizer.id
 authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "get_criteria" {
 api_id          = aws_apigatewayv2_api.main.id
 route_key       = "GET /criteria"
 target          = "integrations/${aws_apigatewayv2_integration.criteria.id}"
 authorizer_id   = aws_apigatewayv2_authorizer.main_authorizer.id
 authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "get_ratings" {
 api_id          = aws_apigatewayv2_api.main.id
 route_key       = "GET /ratings"
 target          = "integrations/${aws_apigatewayv2_integration.ratings.id}"
 authorizer_id   = aws_apigatewayv2_authorizer.main_authorizer.id
 authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_route" "get_projects" {
 api_id          = aws_apigatewayv2_api.main.id
 route_key       = "GET /projects"
 target          = "integrations/${aws_apigatewayv2_integration.ratings.id}"
 authorizer_id   = aws_apigatewayv2_authorizer.main_authorizer.id
 authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_stage" "main_stage"{
 api_id = aws_apigatewayv2_api.main.id
 name   = "${local.app_name}-stage"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_main.arn
    format = jsonencode({
      requestId                      = "$context.requestId",
      extendedRequestId              = "$context.extendedRequestId",
      ip                             = "$context.identity.sourceIp",
      caller                         = "$context.identity.caller",
      user                           = "$context.identity.user",
      userAgent                      = "$context.identity.userAgent",
      requestTime                    = "$context.requestTime",
      requestTimeEpoch               = "$context.requestTimeEpoch",
      httpMethod                     = "$context.httpMethod",
      resourcePath                   = "$context.resourcePath",
      status                         = "$context.status",
      protocol                       = "$context.protocol",
      responseLength                 = "$context.responseLength",
      integrationErrorMessage        = "$context.integrationErrorMessage",
      integrationLatency             = "$context.integrationLatency",
      integrationStatus              = "$context.integration.status",
      errorMessage                   = "$context.error.message",
      authorizerError                = "$context.authorizer.error.message",
      authorizerLatency              = "$context.authorizer.latency",
      accountId                      = "$context.identity.accountId",
      apiId                          = "$context.apiId",
      domainName                     = "$context.domainName",
      domainPrefix                    = "$context.domainPrefix",
      path                           = "$context.path",
      stage                          = "$context.stage",
      requestContextId               = "$context.requestId",
      requestContextAccountId        = "$context.identity.accountId",
      requestContextApiId            = "$context.apiId",
      requestContextDomainName       = "$context.domainName",
      requestContextDomainPrefix      = "$context.domainPrefix",
      requestContextPath             = "$context.path",
      requestContextStage            = "$context.stage",
      requestContextRequestId        = "$context.requestId",
      requestContextRequestTime      = "$context.requestTime",
      requestContextRequestTimeEpoch = "$context.requestTimeEpoch",
      requestContextResourcePath     = "$context.resourcePath",
      requestContextHttpMethod       = "$context.httpMethod",
      requestContextProtocol         = "$context.protocol",
      requestContextStatus           = "$context.status",
      requestContextIntegrationStatus = "$context.integration.status",
      requestContextIntegrationLatency = "$context.integration.latency",
      requestContextIntegrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

 default_route_settings {
   logging_level            = "INFO"
   data_trace_enabled       = true
   detailed_metrics_enabled = true
 }
}

resource "aws_apigatewayv2_domain_name" "main_domain" {
 domain_name = local.api_domain_name
 
 domain_name_configuration {
   certificate_arn = aws_acm_certificate.api_cert.arn
   endpoint_type   = "REGIONAL"
   security_policy = "TLS_1_2"
 }
}

resource "aws_apigatewayv2_api_mapping" "main_api_mapping" {
 api_id      = aws_apigatewayv2_api.main.id
 domain_name = aws_apigatewayv2_domain_name.main_domain.id
 stage       = aws_apigatewayv2_stage.main_stage.id
}

resource "aws_apigatewayv2_deployment" "main_deployment" {
 api_id      = aws_apigatewayv2_api.main.id
 description = "Main Deployment"

 triggers = {
   redployment = sha1(join(",", tolist([
     jsonencode(aws_apigatewayv2_integration.criteria),
     jsonencode(aws_apigatewayv2_integration.ratings),
   ])))
 }

 lifecycle {
   create_before_destroy = true
 }

 depends_on = [
   aws_apigatewayv2_route.post_criteria,
   aws_apigatewayv2_route.post_ratings,
   aws_apigatewayv2_route.get_criteria,
   aws_apigatewayv2_route.get_ratings,
   aws_apigatewayv2_route.get_projects,
   aws_apigatewayv2_route.post_projects,
 ]
}

resource "aws_apigatewayv2_authorizer" "main_authorizer" {
 api_id                            = aws_apigatewayv2_api.main.id
 authorizer_type                   = "REQUEST"
 authorizer_uri                    = aws_lambda_function.authorizer.invoke_arn
 identity_sources                  = ["$request.header.Authorization"]
 name                              = "api-authorizer"
 authorizer_payload_format_version = "2.0"
 enable_simple_responses           = true
 depends_on                        = [aws_lambda_function.authorizer]
}

resource "aws_apigatewayv2_integration" "criteria" {
 api_id                    = aws_apigatewayv2_api.main.id
 integration_type          = "AWS_PROXY"
 connection_type           = "INTERNET"
 description               = "House Hunting Criteria Logic"
 integration_method        = "POST"
 integration_uri           = aws_lambda_function.criteria.invoke_arn
 passthrough_behavior      = "WHEN_NO_MATCH"
 depends_on                = [aws_lambda_function.criteria]
}

resource "aws_apigatewayv2_integration" "ratings" {
 api_id                    = aws_apigatewayv2_api.main.id
 integration_type          = "AWS_PROXY"
 connection_type           = "INTERNET"
 description               = "House Hunting Ratings Logic"
 integration_method        = "POST"
 integration_uri           = aws_lambda_function.ratings.invoke_arn
 passthrough_behavior      = "WHEN_NO_MATCH"
 depends_on                = [aws_lambda_function.ratings]
}

resource "aws_apigatewayv2_integration" "projects" {
 api_id                    = aws_apigatewayv2_api.main.id
 integration_type          = "AWS_PROXY"
 connection_type           = "INTERNET"
 description               = "House Hunting Projects Logic"
 integration_method        = "POST"
 integration_uri           = aws_lambda_function.projects.invoke_arn
 passthrough_behavior      = "WHEN_NO_MATCH"
 depends_on                = [aws_lambda_function.projects]
}