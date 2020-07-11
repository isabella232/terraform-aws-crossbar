# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/efs_file_system.html
resource "aws_efs_file_system" "crossbar-efs1" {
    creation_token = "crossbar-efs1"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
    encrypted = "true"
    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "crossbar-efs1-mnt1" {
    file_system_id  = aws_efs_file_system.crossbar-efs1.id
    subnet_id = aws_subnet.crossbar-vpc1-efs1.id
    security_groups = [aws_security_group.crossbar-efs1.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "crossbar-efs1-mnt2" {
    file_system_id  = aws_efs_file_system.crossbar-efs1.id
    subnet_id = aws_subnet.crossbar-vpc1-efs2.id
    security_groups = [aws_security_group.crossbar-efs1.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_mount_target.html
resource "aws_efs_mount_target" "crossbar-efs1-mnt3" {
    file_system_id  = aws_efs_file_system.crossbar-efs1.id
    subnet_id = aws_subnet.crossbar-vpc1-efs3.id
    security_groups = [aws_security_group.crossbar-efs1.id]
}

# https://www.terraform.io/docs/providers/aws/r/efs_access_point.html
resource "aws_efs_access_point" "crossbar-efs1-master" {
    file_system_id = aws_efs_file_system.crossbar-efs1.id

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

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/efs_access_point.html
resource "aws_efs_access_point" "crossbar-efs1-nodes" {
    file_system_id = aws_efs_file_system.crossbar-efs1.id

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

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

# https://www.terraform.io/docs/providers/aws/r/efs_access_point.html
resource "aws_efs_access_point" "crossbar-efs1_web" {
    file_system_id = aws_efs_file_system.crossbar-efs1.id

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

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}
