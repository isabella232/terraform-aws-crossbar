# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
resource "aws_launch_configuration" "crossbar-cluster1-lc" {
    name_prefix     = "crossbar-cluster1-lc"
    image_id        = var.aws-amis[var.aws-region]
    instance_type   = var.dataplane-instance-type

    key_name        = aws_key_pair.crossbar-admin-keypair.key_name
    security_groups = [
        aws_security_group.crossbar-cluster.id
    ]

    iam_instance_profile = aws_iam_instance_profile.crossbar-ec2profile-cluster.name

    user_data = templatefile("${path.module}/files/setup-cluster.sh", {
        file_system_id = aws_efs_file_system.crossbar-efs1.id,
        access_point_id_nodes = aws_efs_access_point.crossbar-efs1-nodes.id
        access_point_id_web = aws_efs_access_point.crossbar-efs1_web.id

        master_url = "ws://${aws_instance.crossbar-master-node.private_ip}:${var.master-port}/ws"
        master_hostname = aws_instance.crossbar-master-node.private_ip

        master_port = var.master-port
        aws_region = var.aws-region
        aws_account_id = data.aws_caller_identity.current.account_id
    })

    # https://github.com/hashicorp/terraform/issues/532
    # https://www.terraform.io/docs/configuration/resources.html#lifecycle-lifecycle-customizations
    lifecycle {
        create_before_destroy = true
    }

    depends_on = [
          aws_instance.crossbar-master-node
        , aws_efs_file_system.crossbar-efs1
    ]

}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "crossbar-cluster1-asg" {
    name                      = "crossbar-cluster-${var.domain-name}"
    launch_configuration      = aws_launch_configuration.crossbar-cluster1-lc.name

    vpc_zone_identifier       = [
        aws_subnet.crossbar-vpc1-public1.id,
        aws_subnet.crossbar-vpc1-public2.id,
        aws_subnet.crossbar-vpc1-public3.id
    ]

    min_size                  = var.dataplane-min-size
    max_size                  = var.dataplane-max-size
    desired_capacity          = var.dataplane-desired-size

    health_check_grace_period = 300
    health_check_type         = "EC2"

    tag {
        key                 = "Name"
        value               = "Crossbar.io Cloud - ${var.domain-name}"
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
    lifecycle {
        create_before_destroy = true

        # https://www.terraform.io/docs/configuration/resources.html#ignore_changes
        ignore_changes = [
            tags
        ]
    }

    depends_on = [
        aws_launch_configuration.crossbar-cluster1-lc,
        aws_instance.crossbar-master-node
    ]
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
resource "aws_autoscaling_policy" "crossbar-cluster1-cpu-up-policy" {
    name                   = "crossbar-cluster-cpu-policy-${var.domain-name}"
    autoscaling_group_name = aws_autoscaling_group.crossbar-cluster1-asg.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = "1"
    cooldown               = "300"
    policy_type            = "SimpleScaling"

    depends_on = [aws_autoscaling_group.crossbar-cluster1-asg]
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html
resource "aws_cloudwatch_metric_alarm" "crossbar-cluster1-cpu-up-alarm" {
    alarm_name          = "crossbar-cluster-cpu-alarm-${var.domain-name}"
    alarm_description   = "CPU (scale-up) alarm for cluster of domain '${var.domain-name}' fired"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "60"

    dimensions = {
        "AutoScalingGroupName" = aws_autoscaling_group.crossbar-cluster1-asg.name
    }

    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.crossbar-cluster1-cpu-up-policy.arn]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        node = "cluster"
        env = var.env
    }

    depends_on = [aws_autoscaling_group.crossbar-cluster1-asg]
}

#
# scale down alarm
#

# https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
resource "aws_autoscaling_policy" "crossbar-cluster1-cpu-down-policy" {
    name                   = "crossbar-cluster1-cpu-down-policy-${var.domain-name}"
    autoscaling_group_name = aws_autoscaling_group.crossbar-cluster1-asg.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = "-1"
    cooldown               = "300"
    policy_type            = "SimpleScaling"

    depends_on = [aws_autoscaling_group.crossbar-cluster1-asg]
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html
resource "aws_cloudwatch_metric_alarm" "crossbar-cluster1-cpu-down-alarm" {
    alarm_name          = "crossbar-cluster1-cpu-down-alarm-${var.domain-name}"
    alarm_description   = "CPU scale-down alarm for cluster of domain '${var.domain-name}' fired"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "20"

    dimensions = {
        "AutoScalingGroupName" = aws_autoscaling_group.crossbar-cluster1-asg.name
    }

    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.crossbar-cluster1-cpu-down-policy.arn]

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        node = "cluster"
        env = var.env
    }

    depends_on = [aws_autoscaling_group.crossbar-cluster1-asg]
}
