resource "aws_apigatewayv2_api" "main" {
 name          = local.app_name
 protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["http://localhost:5173", "https://house-hunting.hnucamendi.me", "https://hnucamendi.me"]
    allow_headers = ["authorization", "x-authorization-method", "access-control-allow-origin", "content-type"]
    allow_methods = ["GET", "POST", "PUT", "OPTIONS"]
    max_age       = 300
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
 api_id      = aws_apigatewayv2_api.main.id
 name        = "${local.app_name}-stage"
 auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigw_main.arn
    format          = jsonencode({
                        accountId: "$context.accountId",
                        apiId: "$context.apiId",
                        authorizerError: "$context.authorizer.error",
                        authorizerPrincipalId: "$context.authorizer.principalId",
                        awsEndpointRequestId: "$context.awsEndpointRequestId",
                        awsEndpointRequestId2: "$context.awsEndpointRequestId2",
                        customDomainBasePathMatched: "$context.customDomain.basePathMatched",
                        dataProcessed: "$context.dataProcessed",
                        domainName: "$context.domainName",
                        domainPrefix: "$context.domainPrefix",
                        errorMessage: "$context.error.message",
                        errorResponseType: "$context.error.responseType",
                        extendedRequestId: "$context.extendedRequestId",
                        httpMethod: "$context.httpMethod",
                        identityAccountId: "$context.identity.accountId",
                        identityCaller: "$context.identity.caller",
                        identityCognitoAuthenticationProvider: "$context.identity.cognitoAuthenticationProvider",
                        identityCognitoAuthenticationType: "$context.identity.cognitoAuthenticationType",
                        identityCognitoIdentityId: "$context.identity.cognitoIdentityId",
                        identityCognitoIdentityPoolId: "$context.identity.cognitoIdentityPoolId",
                        identityPrincipalOrgId: "$context.identity.principalOrgId",
                        identityClientCertPem: "$context.identity.clientCert.clientCertPem",
                        identityClientCertSubjectDN: "$context.identity.clientCert.subjectDN",
                        identityClientCertIssuerDN: "$context.identity.clientCert.issuerDN",
                        identityClientCertSerialNumber: "$context.identity.clientCert.serialNumber",
                        identityClientCertValidityNotBefore: "$context.identity.clientCert.validity.notBefore",
                        identityClientCertValidityNotAfter: "$context.identity.clientCert.validity.notAfter",
                        identitySourceIp: "$context.identity.sourceIp",
                        identityUser: "$context.identity.user",
                        identityUserAgent: "$context.identity.userAgent",
                        identityUserArn: "$context.identity.userArn",
                        integrationError: "$context.integration.error",
                        integrationIntegrationStatus: "$context.integration.integrationStatus",
                        integrationRequestId: "$context.integration.requestId",
                        lambdaProxyCodeIntegrationStatus: "$context.integration.status",
                        integrationErrorMessage: "$context.integrationErrorMessage",
                        integrationLatency: "$context.integration.latency",
                        integrationLatencyV2: "$context.integrationLatency",
                        integrationStatus: "$context.integrationStatus",
                        path: "$context.path",
                        protocol: "$context.protocol",
                        requestId: "$context.requestId",
                        requestTime: "$context.requestTime",
                        requestTimeEpoch: "$context.requestTimeEpoch",
                        responseLatency: "$context.responseLatency",
                        responseLength: "$context.responseLength",
                        routeKey: "$context.routeKey",
                        stage: "$context.stage",
                        methodStatus: "$context.status"
                      })
  }

 default_route_settings {
   logging_level            = "INFO"
   data_trace_enabled       = true
   detailed_metrics_enabled = true
   throttling_burst_limit   = 5000
   throttling_rate_limit    = 10000
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

resource "aws_apigatewayv2_authorizer" "main_authorizer" {
 api_id                            = aws_apigatewayv2_api.main.id
 authorizer_type                   = "REQUEST"
 authorizer_uri                    = aws_lambda_function.authorizer.invoke_arn
 authorizer_result_ttl_in_seconds  = 0
 identity_sources                  = [""]
 name                              = "api-authorizer"
 authorizer_payload_format_version = "2.0"
 enable_simple_responses           = true
 depends_on                        = [aws_lambda_function.authorizer]
}

resource "aws_apigatewayv2_integration" "criteria" {
 api_id                    = aws_apigatewayv2_api.main.id
 integration_type          = "AWS_PROXY"
 payload_format_version    =  "2.0"
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
 payload_format_version    =  "2.0"
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
 payload_format_version    = "2.0"
 connection_type           = "INTERNET"
 description               = "House Hunting Projects Logic"
 integration_method        = "POST"
 integration_uri           = aws_lambda_function.projects.invoke_arn
 passthrough_behavior      = "WHEN_NO_MATCH"
 depends_on                = [aws_lambda_function.projects]
}
