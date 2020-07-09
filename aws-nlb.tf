# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/lb.html
resource "aws_lb" "crossbar-nlb" {
    name                                = "crossbar-nlb"
    load_balancer_type                  = "network"
    internal                            = false
    enable_cross_zone_load_balancing    = true
    subnets = [
        aws_subnet.crossbar_vpc_public1.id,
        aws_subnet.crossbar_vpc_public2.id,
        aws_subnet.crossbar_vpc_public3.id]

    # FIXME: InvalidConfigurationRequest: Security groups are not supported for load balancers with type 'network'
    # security_groups = [
    #     aws_security_group.crossbar_elb.id
    # ]

    tags = {
        Name = "crossbar-nlb"
    }
}

# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
resource "aws_lb_target_group" "crossbar-nlb-target-group" {
    name        = "crossbar-nlb-target-group"
    port        = 80
    protocol    = "TCP"
    vpc_id      = aws_vpc.crossbar_vpc.id

    # Error: Network Load Balancers do not support Stickiness
    # https://github.com/terraform-providers/terraform-provider-aws/issues/9093
    stickiness {
        enabled = false
        type = "lb_cookie"
    }

    tags = {
        Name = "crossbar-nlb-target-group"
    }
}

# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
resource "aws_lb_listener" "crossbar-nlb-listener" {
    load_balancer_arn = aws_lb.crossbar-nlb.arn
    port              = "80"
    protocol          = "TCP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.crossbar-nlb-target-group.arn
    }
}

resource "aws_lb_listener" "crossbar-nlb-listener-tls" {
    load_balancer_arn = aws_lb.crossbar-nlb.arn
    port              = "443"
    protocol          = "TLS"
    ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
    certificate_arn   = aws_acm_certificate_validation.crossbar_dns_cert_validation.certificate_arn
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.crossbar-nlb-target-group.arn
    }
}
