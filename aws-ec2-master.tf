# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "crossbar-master-node" {
    ami = var.aws-amis[var.aws-region]
    instance_type = var.master-instance-type

    subnet_id = aws_subnet.crossbar-vpc1-master.id
    vpc_security_group_ids = [
        aws_security_group.crossbar-master.id
    ]

    key_name = aws_key_pair.crossbar-admin-keypair.key_name

    iam_instance_profile = aws_iam_instance_profile.crossbar-ec2profile-master.name

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        node = "master"
        env = var.env
    }

    user_data = templatefile("${path.module}/files/setup-master.sh", {
            file_system_id = aws_efs_file_system.crossbar-efs1.id,
            access_point_id_master = aws_efs_access_point.crossbar-efs1-master.id
            access_point_id_nodes = aws_efs_access_point.crossbar-efs1-nodes.id
            master_port = var.master-port
            aws_region = var.aws-region
            aws_account_id = data.aws_caller_identity.current.account_id
    })
}

# resource "aws_network_interface" "crossbar-master-node_nic1" {
#     count = var.enable-master ? 1 : 0

#     subnet_id       = aws_subnet.crossbar-vpc1-master.id

#     # FIXME
#     # private_ips     = ["10.0.10.10"]

#     security_groups = [aws_security_group.crossbar-master.id]

#     attachment {
#         instance  = aws_instance.crossbar-master-node[0].id
#         device_index = 1
#     }

#     tags = {
#         Name = "Crossbar.io Cloud - ${var.domain-name}"
#         node = "master"
#         env = var.env
#     }
# }

resource "aws_eip" "crossbar_master" {
    instance = aws_instance.crossbar-master-node.id
    vpc      = true

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        node = "master"
        env = var.env
    }
}
