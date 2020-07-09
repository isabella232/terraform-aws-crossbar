# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/route53_zone.html
resource "aws_route53_zone" "crossbar_zone" {
    name = var.dns-domain-name
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "crossbar_zonerec_ns" {
    allow_overwrite = true
    name            = var.dns-domain-name
    ttl             = 30
    type            = "NS"
    zone_id         = aws_route53_zone.crossbar_zone.zone_id
    records = [
        aws_route53_zone.crossbar_zone.name_servers.0,
        aws_route53_zone.crossbar_zone.name_servers.1,
        aws_route53_zone.crossbar_zone.name_servers.2,
        aws_route53_zone.crossbar_zone.name_servers.3,
    ]
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "crossbar_zonerec_www" {
    zone_id = aws_route53_zone.crossbar_zone.zone_id
    name    = var.dns-domain-name
    type    = "A"
    alias {
        name                   = aws_lb.crossbar-nlb.dns_name
        zone_id                = aws_lb.crossbar-nlb.zone_id
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "crossbar_zonerec_master" {
    count = var.enable-master ? 1 : 0

    zone_id = aws_route53_zone.crossbar_zone.zone_id
    name    = "master.${var.dns-domain-name}"
    ttl     = 30
    type    = "A"
    # records = [aws_instance.crossbar_node_master[0].public_ip]
    records = [aws_eip.crossbar_master[0].public_ip]
}
