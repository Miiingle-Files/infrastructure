provider "aws" {
  alias  = "route53_region"
  region = "us-east-1"
}

data "aws_route53_zone" "main" {
  provider     = aws.route53_region
  name         = var.dns_root
  private_zone = false
}

resource "aws_acm_certificate" "api_gateway_ssl" {
  domain_name       = "${var.dns_prefix}.${var.dns_root}"
  validation_method = "DNS"

  tags = merge(
    {
      Name = "Cert for the API Gateway ${var.dns_prefix}.${var.dns_root} ${var.org}:${var.env}"
    },
    local.common_tags
  )
}

resource "aws_route53_record" "api_gateway_ssl_cert_validation" {
  provider        = aws.route53_region
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.api_gateway_ssl.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.api_gateway_ssl.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.api_gateway_ssl.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.main.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "api_gateway_ssl_cert_validation" {
  certificate_arn         = aws_acm_certificate.api_gateway_ssl.arn
  validation_record_fqdns = [aws_route53_record.api_gateway_ssl_cert_validation.fqdn]
}

resource "aws_route53_record" "api_gateway_cname" {
  provider   = aws.route53_region

  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.dns_prefix
  type    = "CNAME"
  records = aws_apigatewayv2_domain_name.api_gateway.domain_name_configuration.*.target_domain_name
  ttl     = 60

  depends_on = [aws_apigatewayv2_api_mapping.api_gateway]
}