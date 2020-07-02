# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
resource "aws_launch_configuration" "crossbarfx_cluster_launchconfig" {
    name_prefix     = "crossbarfx_cluster_launchconfig"
    image_id        = var.AMIS[var.AWS_REGION]
    instance_type   = var.INSTANCE_TYPE

    key_name        = aws_key_pair.crossbarfx_keypair.key_name
    security_groups = [
        aws_security_group.crossbarfx_cluster_node.id
    ]

    user_data = templatefile("${path.module}/files/setup-edge.sh", {
            file_system_id = aws_efs_file_system.crossbarfx_efs.id,
            access_point_id_nodes = aws_efs_access_point.crossbarfx_efs_nodes.id
            master_url = "ws://${aws_instance.crossbarfx_node_master.private_ip}:9000/ws"
            master_hostname = aws_instance.crossbarfx_node_master.private_ip
            master_port = 9000
    })
}

# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "crossbarfx_cluster_autoscaling" {
    name                      = "crossbarfx_cluster_autoscaling"
    launch_configuration      = aws_launch_configuration.crossbarfx_cluster_launchconfig.name

    vpc_zone_identifier       = [
        aws_subnet.crossbarfx_vpc_public1.id,
        aws_subnet.crossbarfx_vpc_public2.id,
        aws_subnet.crossbarfx_vpc_public3.id
    ]
    # load_balancers            = [
    #     aws_lb.crossbarfx-nlb.name
    # ]
    # target_group_arns = []

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
