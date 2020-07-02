# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/elb.html
resource "aws_elb" "crossbarfxelb" {
    name            = "crossbarfxelb"
    subnets         = [
        aws_subnet.crossbarfx_vpc_public1.id,
        aws_subnet.crossbarfx_vpc_public2.id,
        aws_subnet.crossbarfx_vpc_public3.id]
    security_groups = [
        aws_security_group.crossbarfx_elb.id
    ]
    cross_zone_load_balancing   = true
    connection_draining         = true
    connection_draining_timeout = 400
    tags = {
        Name = "crossbarfxelb"
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
        ssl_certificate_id = aws_acm_certificate.crossbarfx_dns_cert.id
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
