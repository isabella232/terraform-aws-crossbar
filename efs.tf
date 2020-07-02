###############################################################################
#
# The MIT License (MIT)
#
# Copyright (c) Crossbar.io Technologies GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###############################################################################


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
