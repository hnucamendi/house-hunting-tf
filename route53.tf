resource "aws_acm_certificate" "api_cert" {
  domain_name       = local.api_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name         = "${local.domain_uri}.me"
  private_zone = false
}

resource "aws_route53_record" "api_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "api_validation" {
  certificate_arn = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation_record : record.fqdn]
}

resource "aws_route53_record" "api_record" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.domain_name
      alias  = {
        name = aws_apigatewayv2_domain_name.main_domain.domain_name_configuration[0].target_domain_name
        zone_id = aws_apigatewayv2_domain_name.main_domain.domain_name_configuration[0].hosted_zone_id
      }
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = "A"
  zone_id         = data.aws_route53_zone.zone.zone_id

  alias {
    name                   = each.value.alias.name
    zone_id                = each.value.alias.zone_id
    evaluate_target_health = false
  }
}