# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "crossbar_node_master" {
    count = var.enable-master ? 1 : 0

    ami = var.aws-amis[var.aws-region]
    instance_type = var.master-instance-type
    # master_url = "ws://${self.private_ip}:9000/ws"

    subnet_id = aws_subnet.crossbar_vpc_master.id
    vpc_security_group_ids = [
        aws_security_group.crossbar_master_node.id
    ]

    key_name = aws_key_pair.crossbar_keypair.key_name

    tags = {
        Name = "Crossbar.io FX (Master)"
        node = "master"
        env = "prod"
    }

    user_data = templatefile("${path.module}/files/setup-master.sh", {
            file_system_id = aws_efs_file_system.crossbar_efs.id,
            access_point_id_master = aws_efs_access_point.crossbar_efs_master.id
            access_point_id_nodes = aws_efs_access_point.crossbar_efs_nodes.id
            master_port = 9000
    })
}

resource "aws_network_interface" "crossbar_node_master_nic1" {
    count = var.enable-master ? 1 : 0

    subnet_id       = aws_subnet.crossbar_vpc_master.id
    private_ips     = ["10.0.10.10"]
    security_groups = [aws_security_group.crossbar_master_node.id]
    attachment {
        instance  = aws_instance.crossbar_node_master[0].id
        device_index = 1
    }
}

resource "aws_eip" "crossbar_master" {
    count = var.enable-master ? 1 : 0

    instance = aws_instance.crossbar_node_master[0].id
    vpc      = true
}
