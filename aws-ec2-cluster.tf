# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
resource "aws_launch_configuration" "crossbar_cluster_launchconfig" {
    name_prefix     = "crossbar_cluster_launchconfig"
    image_id        = var.aws-amis[var.aws-region]
    instance_type   = var.dataplane-instance-type

    key_name        = aws_key_pair.crossbar_keypair.key_name
    security_groups = [
        aws_security_group.crossbar_cluster_node.id
    ]

    iam_instance_profile = aws_iam_instance_profile.crossbar-ec2profile-cluster.name

    user_data = templatefile("${path.module}/files/setup-cluster.sh", {
            file_system_id = aws_efs_file_system.crossbar_efs.id,
            access_point_id_nodes = aws_efs_access_point.crossbar_efs_nodes.id
            access_point_id_web = aws_efs_access_point.crossbar_efs_web.id
            master_url = "ws://${aws_instance.crossbar_node_master[0].private_ip}:${var.master-port}/ws"
            master_hostname = aws_instance.crossbar_node_master[0].private_ip
            master_port = var.master-port
            aws_region = var.aws-region
            aws_account_id = data.aws_caller_identity.current.account_id
    })

    # https://github.com/hashicorp/terraform/issues/532
    # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations
    lifecycle {
        create_before_destroy = true
    }
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "crossbar_cluster_autoscaling" {
    name                      = "crossbar_cluster_autoscaling"
    launch_configuration      = aws_launch_configuration.crossbar_cluster_launchconfig.name

    vpc_zone_identifier       = [
        aws_subnet.crossbar_vpc_public1.id,
        aws_subnet.crossbar_vpc_public2.id,
        aws_subnet.crossbar_vpc_public3.id
    ]
    # load_balancers            = [
    #     aws_lb.crossbar-nlb.name
    # ]
    # target_group_arns = []

    min_size                  = var.dataplane-min-size
    max_size                  = var.dataplane-max-size
    desired_capacity          = var.dataplane-desired-size

    health_check_grace_period = 300
    health_check_type         = "EC2"

    tag {
        key                 = "Name"
        value               = "Crossbar.io Cloud - ${var.dns-domain-name}"
        propagate_at_launch = true
    }
    tag {
        key                 = "node"
        value               = "cluster"
        propagate_at_launch = true
    }
    tag {
        key                 = "env"
        value               = var.env
        propagate_at_launch = true
    }

    # https://github.com/hashicorp/terraform/issues/532
    # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations
    depends_on = [aws_launch_configuration.crossbar_cluster_launchconfig]
    lifecycle {
        create_before_destroy = true
    }
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
resource "aws_autoscaling_policy" "crossbar_cluster_cpu_policy" {
    name                   = "crossbar_cluster_cpu_policy"
    autoscaling_group_name = aws_autoscaling_group.crossbar_cluster_autoscaling.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = "1"
    cooldown               = "300"
    policy_type            = "SimpleScaling"
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html
resource "aws_cloudwatch_metric_alarm" "crossbar_cluster_cpu_alarm" {
    alarm_name          = "crossbar_cluster_cpu-alarm"
    alarm_description   = "crossbar_cluster_cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "60"

    dimensions = {
        "AutoScalingGroupName" = aws_autoscaling_group.crossbar_cluster_autoscaling.name
    }

    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.crossbar_cluster_cpu_policy.arn]

    tags = {
        Name = "Crossbar.io Cloud - ${var.dns-domain-name}"
        node = "cluster"
        env = var.env
    }
}

#
# scale down alarm
#

# https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
resource "aws_autoscaling_policy" "crossbar_cluster_cpu_policy_scaledown" {
    name                   = "crossbar_cluster_cpu_olicy_scaledown"
    autoscaling_group_name = aws_autoscaling_group.crossbar_cluster_autoscaling.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = "-1"
    cooldown               = "300"
    policy_type            = "SimpleScaling"
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html
resource "aws_cloudwatch_metric_alarm" "crossbar_cluster_cpu_alarm_scaledown" {
    alarm_name          = "crossbar_cluster_cpu_alarm_scaledown"
    alarm_description   = "crossbar_cluster_cpu_alarm_scaledown"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "10"

    dimensions = {
        "AutoScalingGroupName" = aws_autoscaling_group.crossbar_cluster_autoscaling.name
    }

    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.crossbar_cluster_cpu_policy_scaledown.arn]

    tags = {
        Name = "Crossbar.io Cloud - ${var.dns-domain-name}"
        node = "cluster"
        env = var.env
    }
}
