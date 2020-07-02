# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/route53_zone.html
resource "aws_route53_zone" "crossbarfx_zone" {
    name = var.DOMAIN_NAME
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "crossbarfx_zonerec_ns" {
    allow_overwrite = true
    name            = var.DOMAIN_NAME
    ttl             = 30
    type            = "NS"
    zone_id         = aws_route53_zone.crossbarfx_zone.zone_id
    records = [
        aws_route53_zone.crossbarfx_zone.name_servers.0,
        aws_route53_zone.crossbarfx_zone.name_servers.1,
        aws_route53_zone.crossbarfx_zone.name_servers.2,
        aws_route53_zone.crossbarfx_zone.name_servers.3,
    ]
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "crossbarfx_zonerec_www" {
    zone_id = aws_route53_zone.crossbarfx_zone.zone_id
    name    = var.DOMAIN_NAME
    type    = "A"
    alias {
        name                   = aws_elb.crossbarfxelb.dns_name
        zone_id                = aws_elb.crossbarfxelb.zone_id
        evaluate_target_health = true
    }
}
