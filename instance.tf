# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "crossbarfx_node_master" {
    ami = var.AMIS[var.AWS_REGION]
    instance_type = var.INSTANCE_TYPE

    subnet_id = aws_subnet.crossbarfx_vpc_master.id
    vpc_security_group_ids = [
        aws_security_group.crossbarfx_master_node.id
    ]

    key_name = aws_key_pair.crossbarfx_keypair.key_name

    tags = {
        Name = "Crossbar.io FX (Master)"
        node = "master"
        env = "prod"
    }

    user_data = templatefile("${path.module}/files/setup-master.sh", {
            file_system_id = aws_efs_file_system.crossbarfx_efs.id,
            access_point_id_master = aws_efs_access_point.crossbarfx_efs_master.id
            access_point_id_nodes = aws_efs_access_point.crossbarfx_efs_nodes.id
            master_port = 9000
    })
}
