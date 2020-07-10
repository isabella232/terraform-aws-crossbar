# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/route53_zone.html
resource "aws_route53_zone" "crossbar-zone" {
    name = var.dns-domain-name

    tags = {
        Name = "Crossbar.io Cloud [${var.dns-domain-name}]"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "crossbar-nameserver" {
    zone_id         = aws_route53_zone.crossbar-zone.zone_id
    name            = var.dns-domain-name
    type            = "NS"

    allow_overwrite = true
    ttl             = 30
    records = [
        aws_route53_zone.crossbar-zone.name_servers.0,
        aws_route53_zone.crossbar-zone.name_servers.1,
        aws_route53_zone.crossbar-zone.name_servers.2,
        aws_route53_zone.crossbar-zone.name_servers.3,
    ]
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "crossbar-data" {
    zone_id = aws_route53_zone.crossbar-zone.zone_id
    name    = "data.${var.dns-domain-name}"
    type    = "A"

    alias {
        name                   = aws_lb.crossbar-nlb.dns_name
        zone_id                = aws_lb.crossbar-nlb.zone_id
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "crossbar-master" {
    count = var.enable-master ? 1 : 0
    zone_id = aws_route53_zone.crossbar-zone.zone_id
    name    = "master.${var.dns-domain-name}"
    type    = "A"

    ttl     = 30
    # records = [aws_instance.crossbar_node_master[0].public_ip]
    records = [aws_eip.crossbar_master[0].public_ip]
}


# create a Route53 ALIAS record to the Cloudfront distribution
# resource "aws_route53_record" "crossbar-web-alias" {
#   zone_id = aws_route53_zone.crossbar-zone.zone_id
#   name    = var.dns-domain-name
#   type    = "A"

#   alias {
#     name                   = var.dns-domain-name
#     zone_id                = aws_cloudfront_distribution.crossbar-web.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# create a Route53 CNAME record to the Cloudfront distribution
resource "aws_route53_record" "crossbar-web-cname" {
  zone_id = aws_route53_zone.crossbar-zone.zone_id
  name    = "www.${var.dns-domain-name}"
  type    = "CNAME"

  ttl     = 300
  records = [aws_cloudfront_distribution.crossbar-web.hosted_zone_id]
}
