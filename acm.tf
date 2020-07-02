# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

resource "aws_acm_certificate" "crossbarfx_dns_cert" {
    domain_name       = var.DOMAIN_NAME
    subject_alternative_names = [
        "www.${var.DOMAIN_NAME}"
    ]
    validation_method = "DNS"

    count = "${var.ENABLE_TLS ? 1 : 0}"
}

resource "aws_route53_record" "crossbarfx_dns_cert_validation_cn_rec" {
    name    = aws_acm_certificate.crossbarfx_dns_cert.0.domain_validation_options.0.resource_record_name
    type    = aws_acm_certificate.crossbarfx_dns_cert.0.domain_validation_options.0.resource_record_type
    zone_id = aws_route53_zone.crossbarfx_zone.zone_id
    records = [
        aws_acm_certificate.crossbarfx_dns_cert.0.domain_validation_options.0.resource_record_value
    ]
    ttl     = 60

    count = "${var.ENABLE_TLS ? 1 : 0}"
}

resource "aws_route53_record" "crossbarfx_dns_cert_validation_alt1_rec" {
    name    = aws_acm_certificate.crossbarfx_dns_cert.0.domain_validation_options.1.resource_record_name
    type    = aws_acm_certificate.crossbarfx_dns_cert.0.domain_validation_options.1.resource_record_type
    zone_id = aws_route53_zone.crossbarfx_zone.zone_id
    records = [
        aws_acm_certificate.crossbarfx_dns_cert.0.domain_validation_options.1.resource_record_value
    ]
    ttl     = 60

    count = "${var.ENABLE_TLS ? 1 : 0}"
}

resource "aws_acm_certificate_validation" "crossbarfx_dns_cert_validation" {
    certificate_arn = aws_acm_certificate.crossbarfx_dns_cert.0.arn
    validation_record_fqdns = [
        aws_route53_record.crossbarfx_dns_cert_validation_cn_rec.0.fqdn,
        aws_route53_record.crossbarfx_dns_cert_validation_alt1_rec.0.fqdn
    ]

    count = "${var.ENABLE_TLS ? 1 : 0}"
}
