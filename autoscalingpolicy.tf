# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

#
# scale up alarm
#

# https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
resource "aws_autoscaling_policy" "example-cpu-policy" {
    name                   = "example-cpu-policy"
    autoscaling_group_name = aws_autoscaling_group.autoscaling1.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = "1"
    cooldown               = "300"
    policy_type            = "SimpleScaling"
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html
resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
    alarm_name          = "example-cpu-alarm"
    alarm_description   = "example-cpu-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "60"

    dimensions = {
        "AutoScalingGroupName" = aws_autoscaling_group.autoscaling1.name
    }

    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.example-cpu-policy.arn]
}

#
# scale down alarm
#

# https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
resource "aws_autoscaling_policy" "example-cpu-policy-scaledown" {
    name                   = "example-cpu-policy-scaledown"
    autoscaling_group_name = aws_autoscaling_group.autoscaling1.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = "-1"
    cooldown               = "300"
    policy_type            = "SimpleScaling"
}

# https://www.terraform.io/docs/providers/aws/r/cloudwatch_metric_alarm.html
resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm-scaledown" {
    alarm_name          = "example-cpu-alarm-scaledown"
    alarm_description   = "example-cpu-alarm-scaledown"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = "2"
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = "120"
    statistic           = "Average"
    threshold           = "10"

    dimensions = {
        "AutoScalingGroupName" = aws_autoscaling_group.autoscaling1.name
    }

    actions_enabled = true
    alarm_actions   = [aws_autoscaling_policy.example-cpu-policy-scaledown.arn]
}
