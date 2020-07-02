# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/efs_file_system.html
resource "aws_efs_file_system" "efs1" {
    creation_token = "efs1"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
    encrypted = "true"
    tags = {
        Name = "efs1"
    }
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "efs-mt1" {
    file_system_id  = aws_efs_file_system.efs1.id
    subnet_id = aws_subnet.vpc1-public-1.id
    security_groups = [aws_security_group.ingress-efs.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "efs-mt2" {
    file_system_id  = aws_efs_file_system.efs1.id
    subnet_id = aws_subnet.vpc1-public-2.id
    security_groups = [aws_security_group.ingress-efs.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "efs-mt3" {
    file_system_id  = aws_efs_file_system.efs1.id
    subnet_id = aws_subnet.vpc1-public-3.id
    security_groups = [aws_security_group.ingress-efs.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_access_point.html
resource "aws_efs_access_point" "efs-master" {
    file_system_id = aws_efs_file_system.efs1.id
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
resource "aws_efs_access_point" "efs-home" {
    file_system_id = aws_efs_file_system.efs1.id
    root_directory {
        path = "/home"
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
