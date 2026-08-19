resource "aws_acm_certificate" "acm" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


# Validation record

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.hosted_zone_id

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}


resource "aws_acm_certificate_validation" "acm" {
  certificate_arn = aws_acm_certificate.acm.arn

  validation_record_fqdns = [
    for record in aws_route53_record.validation : record.fqdn
  ]
}
