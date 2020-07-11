# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "current" {}

# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2.html

#
# EC2/IAM user and profile for: master node
#

resource "aws_iam_role" "crossbar-ec2iam-master" {
    name = "crossbar-ec2iam-master"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_iam_role_policy" "crossbar-ec2policy-master" {
    name = "crossbar-ec2policy-master"
    role = aws_iam_role.crossbar-ec2iam-master.name

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "AllowAccessBackupsBucket",
        "Action": [
            "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "${aws_s3_bucket.crossbar-backup.arn}"
    },
    {
        "Sid": "AllowCreateInstanceTags",
        "Effect": "Allow",
        "Action": [
            "ec2:CreateTags"
        ],
        "Resource": [
            "arn:aws:ec2:${var.aws-region}:${data.aws_caller_identity.current.account_id}:instance/*",
            "arn:aws:ec2:${var.aws-region}:${data.aws_caller_identity.current.account_id}:volume/*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "crossbar-ec2profile-master" {
    name = "crossbar-ec2profile-master"
    role = aws_iam_role.crossbar-ec2iam-master.name
}


#
# EC2/IAM user and profile for: cluster nodes
#

resource "aws_iam_role" "crossbar-ec2iam-cluster" {
    name = "crossbar-ec2iam-cluster"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_iam_role_policy" "crossbar-ec2policy-cluster" {
    name = "crossbar-ec2policy-cluster"
    role = aws_iam_role.crossbar-ec2iam-cluster.name

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "AllowAccessBackupsBucket",
        "Action": [
            "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "${aws_s3_bucket.crossbar-backup.arn}"
    },
    {
        "Sid": "AllowCreateInstanceTags",
        "Effect": "Allow",
        "Action": [
            "ec2:CreateTags"
        ],
        "Resource": [
            "arn:aws:ec2:${var.aws-region}:${data.aws_caller_identity.current.account_id}:instance/*",
            "arn:aws:ec2:${var.aws-region}:${data.aws_caller_identity.current.account_id}:volume/*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "crossbar-ec2profile-cluster" {
    name = "crossbar-ec2profile-cluster"
    role = aws_iam_role.crossbar-ec2iam-cluster.name
}
