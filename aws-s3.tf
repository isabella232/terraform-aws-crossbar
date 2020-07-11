# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

#
# web
#
resource "aws_cloudfront_origin_access_identity" "crossbar-web" {
    comment = "crossbar-web"
}

data "aws_iam_policy_document" "crossbar-web-read-bucket" {
    statement {
        actions   = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.crossbar-web.arn}/*"]

        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.crossbar-web.iam_arn]
        }
    }

    statement {
        actions   = ["s3:ListBucket"]
        resources = [aws_s3_bucket.crossbar-web.arn]

        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.crossbar-web.iam_arn]
        }
    }
}

resource "aws_s3_bucket_policy" "crossbar-web-read" {
    bucket = aws_s3_bucket.crossbar-web.id

    policy = data.aws_iam_policy_document.crossbar-web-read-bucket.json
}

# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "crossbar-web" {
    bucket = var.web-bucket
    force_destroy = true
    acl    = "public-read"

    website {
        index_document = "index.html"
    }

    logging {
        target_bucket = aws_s3_bucket.crossbar-weblog.id
        target_prefix = "web/"
    }

    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}

resource "aws_s3_bucket_public_access_block" "crossbar-web-public" {
    bucket = aws_s3_bucket.crossbar-web.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = false
}

# https://www.terraform.io/docs/providers/aws/r/s3_bucket_object.html
# resource "aws_s3_bucket_object" "crossbar-web-index-file" {
#     bucket = aws_s3_bucket.crossbar-web.id
#     acl    = "public-read"
#     key    = "index.html"

#     # source = "files/index.html"
#     content = templatefile("${path.module}/files/index.html", {
#         file_system_id = aws_efs_file_system.crossbar-efs1.id,
#         dns_domain_name = var.domain-name
#     })
# }



#
# weblog
#
resource "aws_s3_bucket" "crossbar-weblog" {
    bucket  = var.weblog-bucket
    force_destroy = true
    acl     = "log-delivery-write"
    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}


#
# backup
#
resource "aws_s3_bucket" "crossbar-backup" {
    bucket  = var.backup-bucket
    acl     = "private"
    tags = {
        Name = "Crossbar.io Cloud - ${var.domain-name}"
        env = var.env
    }
}
