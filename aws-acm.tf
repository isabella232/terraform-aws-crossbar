# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

#
# - <domain-name>
# - www.<domain-name>
#

# Important: needed because certificate for cloudfront must be in us-east-1
# See: https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-invalid-viewer-certificate/
provider "aws" {
    alias = "virginia"
    region = "us-east-1"
}

# TLS certificate for domain, managed (auto-refreshed) by AWS
resource "aws_acm_certificate" "crossbar-tls-cert1" {
    # must be in us-east-1 region for use with Cloudfront
    provider = aws.virginia

    # verify certificate using DNS records created in Route 53
    validation_method = "DNS"

    # the certs CN:
    domain_name       = var.domain-name

    # the certs SANs:
    #
    # IMPORTANT: only use 1 SAN currently, as there is an open issue when using _multipe_ SANs:
    # https://github.com/terraform-providers/terraform-provider-aws/issues/8531
    subject_alternative_names = [
        "www.${var.domain-name}"
    ]

    lifecycle {
        create_before_destroy = true
    }

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

# verification record for cert CN
resource "aws_route53_record" "crossbar-tls-cert1-validation-cn" {
    # must be in us-east-1 region for use with Cloudfront
    provider = aws.virginia


    name    = aws_acm_certificate.crossbar-tls-cert1.domain_validation_options.0.resource_record_name
    type    = aws_acm_certificate.crossbar-tls-cert1.domain_validation_options.0.resource_record_type
    zone_id = aws_route53_zone.crossbar-zone.zone_id
    records = [
        aws_acm_certificate.crossbar-tls-cert1.domain_validation_options.0.resource_record_value
    ]
    ttl     = 60
}

# verification record for cert SAN[0]
resource "aws_route53_record" "crossbar-tls-cert1-validation-alt1" {
    # must be in us-east-1 region for use with Cloudfront
    provider = aws.virginia

    name    = aws_acm_certificate.crossbar-tls-cert1.domain_validation_options.1.resource_record_name
    type    = aws_acm_certificate.crossbar-tls-cert1.domain_validation_options.1.resource_record_type
    zone_id = aws_route53_zone.crossbar-zone.zone_id
    records = [
        aws_acm_certificate.crossbar-tls-cert1.domain_validation_options.1.resource_record_value
    ]
    ttl     = 60
}

# certificate verification record
resource "aws_acm_certificate_validation" "crossbar-tls-cert1-validation" {
    # must be in us-east-1 region for use with Cloudfront
    provider = aws.virginia

    certificate_arn = aws_acm_certificate.crossbar-tls-cert1.arn
    validation_record_fqdns = [
        aws_route53_record.crossbar-tls-cert1-validation-cn.fqdn,
        aws_route53_record.crossbar-tls-cert1-validation-alt1.fqdn
    ]
}


#
# - data.<domain-name>
# - *.data.<domain-name>
#

# TLS certificate for domain, managed (auto-refreshed) by AWS
resource "aws_acm_certificate" "crossbar-tls-cert2" {
    # verify certificate using DNS records created in Route 53
    validation_method = "DNS"

    # the certs CN:
    domain_name       = "data.${var.domain-name}"

    # the certs SANs:
    #
    # IMPORTANT: only use 1 SAN currently, as there is an open issue when using _multipe_ SANs:
    # https://github.com/terraform-providers/terraform-provider-aws/issues/8531
    # subject_alternative_names = [
    #     "*.data.${var.domain-name}"
    # ]

    lifecycle {
        create_before_destroy = true
    }

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

# verification record for cert CN
resource "aws_route53_record" "crossbar-tls-cert2-validation-cn" {
    name    = aws_acm_certificate.crossbar-tls-cert2.domain_validation_options.0.resource_record_name
    type    = aws_acm_certificate.crossbar-tls-cert2.domain_validation_options.0.resource_record_type
    zone_id = aws_route53_zone.crossbar-zone.zone_id
    records = [
        aws_acm_certificate.crossbar-tls-cert2.domain_validation_options.0.resource_record_value
    ]
    ttl     = 60
}

# verification record for cert SAN[0]
# resource "aws_route53_record" "crossbar-tls-cert2-validation-alt1" {
#     name    = aws_acm_certificate.crossbar-tls-cert2.domain_validation_options.1.resource_record_name
#     type    = aws_acm_certificate.crossbar-tls-cert2.domain_validation_options.1.resource_record_type
#     zone_id = aws_route53_zone.crossbar-zone.zone_id
#     records = [
#         aws_acm_certificate.crossbar-tls-cert2.domain_validation_options.1.resource_record_value
#     ]
#     ttl     = 60
# }

# certificate verification record
resource "aws_acm_certificate_validation" "crossbar-tls-cert2-validation" {
    certificate_arn = aws_acm_certificate.crossbar-tls-cert2.arn
    validation_record_fqdns = [
        aws_route53_record.crossbar-tls-cert2-validation-cn.fqdn
        #, aws_route53_record.crossbar-tls-cert2-validation-alt1.fqdn
    ]
}


#
# - master.<domain-name>
#

# TLS certificate for domain, managed (auto-refreshed) by AWS
resource "aws_acm_certificate" "crossbar-tls-cert3" {
    # verify certificate using DNS records created in Route 53
    validation_method = "DNS"

    # the certs CN:
    domain_name       = "master.${var.domain-name}"

    lifecycle {
        create_before_destroy = true
    }
}

# verification record for cert CN
resource "aws_route53_record" "crossbar-tls-cert3-validation-cn" {
    name    = aws_acm_certificate.crossbar-tls-cert3.domain_validation_options.0.resource_record_name
    type    = aws_acm_certificate.crossbar-tls-cert3.domain_validation_options.0.resource_record_type
    zone_id = aws_route53_zone.crossbar-zone.zone_id
    records = [
        aws_acm_certificate.crossbar-tls-cert3.domain_validation_options.0.resource_record_value
    ]
    ttl     = 60
}

# certificate verification record
resource "aws_acm_certificate_validation" "crossbar-tls-cert3-validation" {
    certificate_arn = aws_acm_certificate.crossbar-tls-cert3.arn
    validation_record_fqdns = [
        aws_route53_record.crossbar-tls-cert3-validation-cn.fqdn
    ]
}
