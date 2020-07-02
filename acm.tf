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


resource "aws_acm_certificate" "cert" {
    domain_name       = var.DOMAIN_NAME
    subject_alternative_names = [
        "www.idma2020.de"
    ]
    validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
    name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
    type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
    zone_id = aws_route53_zone.zone.zone_id
    records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
    ttl     = 60
}

resource "aws_route53_record" "cert_validation_alt1" {
    name    = aws_acm_certificate.cert.domain_validation_options.1.resource_record_name
    type    = aws_acm_certificate.cert.domain_validation_options.1.resource_record_type
    zone_id = aws_route53_zone.zone.zone_id
    records = [aws_acm_certificate.cert.domain_validation_options.1.resource_record_value]
    ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
    certificate_arn = aws_acm_certificate.cert.arn
    validation_record_fqdns = [
        aws_route53_record.cert_validation.fqdn,
        aws_route53_record.cert_validation_alt1.fqdn
    ]
}
