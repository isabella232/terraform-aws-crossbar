# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "master" {
    ami = var.AMIS[var.AWS_REGION]
    instance_type = var.INSTANCE_TYPE

    subnet_id = aws_subnet.vpc1-master.id
    vpc_security_group_ids = [aws_security_group.master.id]

    key_name = aws_key_pair.keypair1.key_name

    tags = {
        Name = "Crossbar.io FX (Master)"
        node = "master"
        env = "prod"
    }

    user_data = templatefile("${path.module}/files/setup-master.sh", {
            file_system_id = aws_efs_file_system.efs1.id,
            access_point_id_home = aws_efs_access_point.efs-home.id
            access_point_id_master = aws_efs_access_point.efs-master.id
            master_port = 9000
    })
}
