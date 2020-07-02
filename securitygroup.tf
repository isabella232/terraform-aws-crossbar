# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

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
