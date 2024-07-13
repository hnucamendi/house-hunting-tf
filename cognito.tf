resource "aws_cognito_user_pool" "main" {
  name = "${local.app_name}-user-pool"

  auto_verified_attributes  = ["email"]
  username_attributes      = ["email"]

  email_configuration {
    email_sending_account = "DEVELOPER"
    from_email_address    = "HomeMendi <no-reply@${local.domain_name}>"
    source_arn            = aws_ses_domain_identity.identity.arn
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = false
    require_symbols   = false
  }

schema {
  attribute_data_type      = "String" 
  developer_only_attribute = false
  mutable                  = true 
  name                     = "birthdate" 
  required                 = false 

  string_attribute_constraints {
      max_length = "10"
      min_length = "4"
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "${local.app_name}-user-pool-client"
  user_pool_id                         = aws_cognito_user_pool.main.id
  callback_urls                        = ["https://hnucamendi.com/projects/", "http://localhost:5173/projects/"]
  logout_urls                          = ["https://hnucamendi.com/", "http://localhost:5173/"]
  explicit_auth_flows                   = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows                   = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  allowed_oauth_flows_user_pool_client  = true
  generate_secret                      = false
  refresh_token_validity               = 1
  access_token_validity                = 60
  id_token_validity                    = 60
  token_validity_units {
    refresh_token = "days"
    access_token  = "minutes"
    id_token      = "minutes"
  }

  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain          = local.auth_domain_name
  certificate_arn  = aws_acm_certificate.auth_cert.arn
  user_pool_id    = aws_cognito_user_pool.main.id
}

resource "aws_route53_record" "cognito_auth" {
  name = aws_cognito_user_pool_domain.main.domain
  type = "A"
  zone_id = data.aws_route53_zone.zone.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.main.cloudfront_distribution
    zone_id                = aws_cognito_user_pool_domain.main.cloudfront_distribution_zone_id
  }
}

resource "aws_route53_record" "ses_verification" {
  name    = "_amazonses.${local.domain_name}"
  type    = "TXT"
  zone_id = data.aws_route53_zone.zone.zone_id
  ttl     = 600
  records = [aws_ses_domain_identity.identity.verification_token]
}

resource "aws_route53_record" "ses_dmarc" {
  name    = "_dmarc.${local.domain_name}"
  type    = "TXT"
  zone_id = data.aws_route53_zone.zone.zone_id
  ttl     = 300
  records = ["v=DMARC1; p=quarantine"]
}

resource "aws_route53_record" "ses_dkim" {
  for_each = toset(aws_ses_domain_dkim.dkim.dkim_tokens)

  name    = "${each.value}._domainkey.${local.domain_name}"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.zone.zone_id
  ttl     = 600
  records = ["${each.value}.dkim.amazonses.com"]
}

resource "aws_ses_domain_identity" "identity" {
  domain = local.domain_name
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = aws_ses_domain_identity.identity.domain 
}

resource "aws_ses_domain_identity_verification" "domain_verification" {
  domain = aws_ses_domain_identity.identity.id

  depends_on = [aws_route53_record.ses_verification]
}
