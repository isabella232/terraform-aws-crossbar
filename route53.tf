###############################################################################
#
# The MIT License (MIT)
#
# Copyright (c) Crossbar.io Technologies GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################


# https://www.terraform.io/docs/providers/aws/r/route53_zone.html
resource "aws_route53_zone" "zone" {
    name = var.DOMAIN_NAME
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "zone_ns" {
    allow_overwrite = true
    name            = var.DOMAIN_NAME
    ttl             = 30
    type            = "NS"
    zone_id         = aws_route53_zone.zone.zone_id
    records = [
        aws_route53_zone.zone.name_servers.0,
        aws_route53_zone.zone.name_servers.1,
        aws_route53_zone.zone.name_servers.2,
        aws_route53_zone.zone.name_servers.3,
    ]
}

# https://www.terraform.io/docs/providers/aws/r/route53_record.html
resource "aws_route53_record" "www" {
    zone_id = aws_route53_zone.zone.zone_id
    name    = "idma2020.de"
    type    = "A"
    alias {
        name                   = aws_elb.elb1.dns_name
        zone_id                = aws_elb.elb1.zone_id
        evaluate_target_health = true
    }
}
