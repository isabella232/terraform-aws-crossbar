# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

#
# scale up alarm
#

# https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
resource "aws_autoscaling_policy" "crossbarfx_cluster_cpu_policy" {
    name                   = "crossbarfx_cluster_cpu_policy"
    autoscaling_group_name = aws_autoscaling_group.crossbarfx_cluster_autoscaling.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = "1"
    cooldown               = "300"
    policy_type            = "SimpleScaling"
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html
resource "aws_cloudwatch_metric_alarm" "crossbarfx_cluster_cpu_alarm" {
    alarm_name          = "crossbarfx_cluster_cpu-alarm"
    alarm_description   = "crossbarfx_cluster_cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "60"

    dimensions = {
        "AutoScalingGroupName" = aws_autoscaling_group.crossbarfx_cluster_autoscaling.name
    }

    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.crossbarfx_cluster_cpu_policy.arn]
}

#
# scale down alarm
#

# https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
resource "aws_autoscaling_policy" "crossbarfx_cluster_cpu_policy_scaledown" {
    name                   = "crossbarfx_cluster_cpu_olicy_scaledown"
    autoscaling_group_name = aws_autoscaling_group.crossbarfx_cluster_autoscaling.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = "-1"
    cooldown               = "300"
    policy_type            = "SimpleScaling"
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html
resource "aws_cloudwatch_metric_alarm" "crossbarfx_cluster_cpu_alarm_scaledown" {
    alarm_name          = "crossbarfx_cluster_cpu_alarm_scaledown"
    alarm_description   = "crossbarfx_cluster_cpu_alarm_scaledown"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "10"

    dimensions = {
        "AutoScalingGroupName" = aws_autoscaling_group.crossbarfx_cluster_autoscaling.name
    }

    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.crossbarfx_cluster_cpu_policy_scaledown.arn]
}
