# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/lb.html
resource "aws_lb" "crossbar-nlb1" {
    name                                = "crossbar-nlb1"
    load_balancer_type                  = "network"
    internal                            = false
    enable_cross_zone_load_balancing    = true
    subnets = [
        aws_subnet.crossbar-vpc1-public1.id,
        aws_subnet.crossbar-vpc1-public2.id,
        aws_subnet.crossbar-vpc1-public3.id
    ]

    # FIXME: InvalidConfigurationRequest: Security groups are not supported for load balancers with type 'network'
    # security_groups = [
    #     aws_security_group.crossbar-nlb1.id
    # ]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
resource "aws_lb_target_group" "crossbar-nlb1-targets" {
    name        = "crossbar-nlb1-targets"
    port        = 8080
    protocol    = "TCP"
    vpc_id      = aws_vpc.crossbar-vpc1.id

    # Error: Network Load Balancers do not support Stickiness
    # https://github.com/terraform-providers/terraform-provider-aws/issues/9093
    stickiness {
        enabled = false
        type = "lb_cookie"
    }

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/lb_listener.html
# resource "aws_lb_listener" "crossbar-nlb1-listener1" {
#     load_balancer_arn = aws_lb.crossbar-nlb1.arn
#     port              = "80"
#     protocol          = "TCP"
#     default_action {
#         type             = "forward"
#         target_group_arn = aws_lb_target_group.crossbar-nlb-target-group.arn
#     }

#     depends_on = [aws_lb_target_group.crossbar-nlb1-targets]
# }

resource "aws_lb_listener" "crossbar-nlb1-listener1" {
    load_balancer_arn = aws_lb.crossbar-nlb1.arn
    port              = "80"
    protocol          = "HTTP"
    default_action {
        type = "redirect"
        redirect {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
        }
    }

    depends_on = [aws_lb_target_group.crossbar-nlb1-targets]
}


resource "aws_lb_listener" "crossbar-nlb1-listener2" {
    load_balancer_arn = aws_lb.crossbar-nlb1.arn
    port              = "443"
    protocol          = "TLS"
    ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2019-08"
    certificate_arn   = aws_acm_certificate_validation.crossbar_dns_cert2_validation.certificate_arn
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.crossbar-nlb1-targets.arn
    }

    depends_on = [aws_lb_target_group.crossbar-nlb1-targets]
}

# resource "aws_lb_target_group_attachment" "crossbar-nlb-target-group-attachment" {
#     target_group_arn = aws_lb_target_group.crossbar-nlb-target-group.arn
#     target_id        = aws_autoscaling_group.crossbar-cluster1-asg.id
#     port             = 8080
# }

resource "aws_autoscaling_attachment" "crossbar-nlb1-asc-attachment1" {
    alb_target_group_arn   = aws_lb_target_group.crossbar-nlb1-targets.arn
    autoscaling_group_name = aws_autoscaling_group.crossbar-cluster1-asg.id
}
