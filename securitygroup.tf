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


# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "myinstance" {
    vpc_id      = aws_vpc.vpc1.id
    name        = "myinstance"
    description = "security group for my instance"
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.elb-securitygroup.id]
    }
    ingress {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        security_groups = [aws_security_group.elb-securitygroup.id]
    }
    tags = {
        Name = "myinstance"
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "master" {
    vpc_id      = aws_vpc.vpc1.id
    name        = "master"
    description = "security group for master nodes"
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 9000
        to_port         = 9000
        protocol        = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "master"
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "elb-securitygroup" {
    vpc_id      = aws_vpc.vpc1.id
    name        = "elb"
    description = "security group for load balancer"
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "elb"
    }
}

# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "ingress-efs" {
    name = "ingress-efs-sg"
    vpc_id = aws_vpc.vpc1.id

    // NFS
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
    }

    // Terraform removes the default rule
    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }
}
