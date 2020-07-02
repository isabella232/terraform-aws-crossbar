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


# https://www.terraform.io/docs/providers/aws/r/elb.html
resource "aws_elb" "elb1" {
    name            = "elb1"
    subnets         = [aws_subnet.vpc1-public-1.id, aws_subnet.vpc1-public-2.id, aws_subnet.vpc1-public-3.id]
    security_groups = [aws_security_group.elb-securitygroup.id]
    cross_zone_load_balancing   = true
    connection_draining         = true
    connection_draining_timeout = 400
    tags = {
        Name = "elb1"
    }

    listener {
        lb_port            = 80
        lb_protocol        = "http"
        instance_port      = 8080
        instance_protocol  = "http"
    }

    listener {
        lb_port            = 443
        lb_protocol        = "https"
        ssl_certificate_id = aws_acm_certificate.cert.id
        instance_port      = 8080
        instance_protocol  = "http"
    }

    health_check {
        target              = "HTTP:8080/"
        interval            = 30
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
    }
}


# FIXME: migrate to NLB
# https://www.terraform.io/docs/providers/aws/r/lb.html
# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
