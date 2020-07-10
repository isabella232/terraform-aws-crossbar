# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/efs_file_system.html
resource "aws_efs_file_system" "crossbar_efs" {
    creation_token = "crossbar_efs"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
    encrypted = "true"
    tags = {
        Name = "crossbar_efs"
    }
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "crossbar_efs_mt1" {
    file_system_id  = aws_efs_file_system.crossbar_efs.id
    subnet_id = aws_subnet.crossbar_vpc_efs1.id
    security_groups = [aws_security_group.crossbar_efs.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "crossbar_efs_mt2" {
    file_system_id  = aws_efs_file_system.crossbar_efs.id
    subnet_id = aws_subnet.crossbar_vpc_efs2.id
    security_groups = [aws_security_group.crossbar_efs.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "crossbar_efs_mt3" {
    file_system_id  = aws_efs_file_system.crossbar_efs.id
    subnet_id = aws_subnet.crossbar_vpc_efs3.id
    security_groups = [aws_security_group.crossbar_efs.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_access_point.html
resource "aws_efs_access_point" "crossbar_efs_master" {
    file_system_id = aws_efs_file_system.crossbar_efs.id
    root_directory {
        path = "/master"
        creation_info {
            owner_gid   = 1000
            owner_uid   = 1000
            permissions = "700"
        }
    }
    posix_user {
        gid = 1000
        uid = 1000
    }
}

# https://www.terraform.io/docs/providers/aws/r/efs_access_point.html
resource "aws_efs_access_point" "crossbar_efs_nodes" {
    file_system_id = aws_efs_file_system.crossbar_efs.id
    root_directory {
        path = "/nodes"
        creation_info {
            owner_gid   = 1000
            owner_uid   = 1000
            permissions = "700"
        }
    }
    posix_user {
        gid = 1000
        uid = 1000
    }
}

# https://www.terraform.io/docs/providers/aws/r/efs_access_point.html
resource "aws_efs_access_point" "crossbar_efs_web" {
    file_system_id = aws_efs_file_system.crossbar_efs.id
    root_directory {
        path = "/web"
        creation_info {
            owner_gid   = 1000
            owner_uid   = 1000
            permissions = "700"
        }
    }
    posix_user {
        gid = 1000
        uid = 1000
    }
}
