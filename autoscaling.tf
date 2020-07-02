# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
resource "aws_launch_configuration" "launchconfig1" {
    name_prefix     = "launchconfig1"
    image_id        = var.AMIS[var.AWS_REGION]
    instance_type   = var.INSTANCE_TYPE

    key_name        = aws_key_pair.keypair1.key_name
    security_groups = [aws_security_group.myinstance.id]

    user_data       = templatefile("files/setup-edge.sh", {
            file_system_id = aws_efs_file_system.efs1.id,
            access_point_id_home = aws_efs_access_point.efs-home.id
            master_url = "ws://${aws_instance.master.private_ip}:9000/ws"
            master_hostname = aws_instance.master.private_ip
            master_port = 9000
        }
    )
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "autoscaling1" {
    name                      = "autoscaling1"
    launch_configuration      = aws_launch_configuration.launchconfig1.name

    vpc_zone_identifier       = [aws_subnet.vpc1-public-1.id, aws_subnet.vpc1-public-2.id, aws_subnet.vpc1-public-3.id]
    load_balancers            = [aws_elb.elb1.name]

    min_size                  = 2
    max_size                  = 2
    health_check_grace_period = 300
    health_check_type         = "EC2"

    tag {
        key                 = "Name"
        value               = "Crossbar.io FX (Edge)"
        propagate_at_launch = true
    }
    tag {
        key                 = "node"
        value               = "edge"
        propagate_at_launch = true
    }
    tag {
        key                 = "env"
        value               = "prod"
        propagate_at_launch = true
    }
}
