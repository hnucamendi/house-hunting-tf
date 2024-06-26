locals {
  sub_domain_uri   = "house-hunting"
  domain_uri       = "hnucamendi"
  domain_name      = "${local.domain_uri}.net"
  cdn_domain_name  = "cdn.${local.domain_name}"
  auth_domain_name = "auth.${local.domain_name}"
  api_domain_name  = "api.${local.domain_name}"

  app_name = "house-hunting"
}