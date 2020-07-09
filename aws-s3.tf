# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

#
# web
#
resource "aws_cloudfront_origin_access_identity" "crossbarfx-web" {
    comment = "crossbarfx-web"
}

data "aws_iam_policy_document" "read-crossbarfx-web-bucket" {
    statement {
        actions   = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.crossbarfx-web.arn}/*"]

        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.crossbarfx-web.iam_arn]
        }
    }

    statement {
        actions   = ["s3:ListBucket"]
        resources = [aws_s3_bucket.crossbarfx-web.arn]

        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.crossbarfx-web.iam_arn]
        }
    }
}

# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "crossbarfx-web" {
    bucket = var.domain-web-bucket
    acl    = "public-read"

    website {
        index_document = "index.html"
    }

    logging {
        target_bucket = aws_s3_bucket.crossbarfx-weblog.id
        target_prefix = "web/"
    }

    tags    = {
        Name = "crossbarfx-web"
    }
}

resource "aws_s3_bucket_policy" "read-crossbarfx-web" {
    bucket = aws_s3_bucket.crossbarfx-web.id

    policy = data.aws_iam_policy_document.read-crossbarfx-web-bucket.json
}

resource "aws_s3_bucket_public_access_block" "public-access-crossbarfx-web" {
    bucket = aws_s3_bucket.crossbarfx-web.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = false
}


#
# download
#
resource "aws_cloudfront_origin_access_identity" "crossbarfx-download" {
    comment = "crossbarfx-download"
}

data "aws_iam_policy_document" "read-crossbarfx-download-bucket" {
    statement {
        actions   = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.crossbarfx-download.arn}/*"]

        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.crossbarfx-download.iam_arn]
        }
    }

    statement {
        actions   = ["s3:ListBucket"]
        resources = [aws_s3_bucket.crossbarfx-download.arn]

        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.crossbarfx-download.iam_arn]
        }
    }
}

resource "aws_s3_bucket" "crossbarfx-download" {
    bucket  = var.domain-download-bucket
    acl    = "public-read"

    website {
        index_document = "index.html"
    }

    logging {
        target_bucket = aws_s3_bucket.crossbarfx-weblog.id
        target_prefix = "download/"
    }

    tags    = {
        Name = "crossbarfx-download"
    }
}

resource "aws_s3_bucket_policy" "read-crossbarfx-download" {
    bucket = aws_s3_bucket.crossbarfx-download.id

    policy = data.aws_iam_policy_document.read-crossbarfx-download-bucket.json
}

resource "aws_s3_bucket_public_access_block" "public-access-crossbarfx-download" {
    bucket = aws_s3_bucket.crossbarfx-download.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = false
}


#
# weblog
#
resource "aws_s3_bucket" "crossbarfx-weblog" {
    bucket  = var.domain-weblog-bucket
    acl     = "log-delivery-write"
    tags    = {
        Name = "crossbarfx-weblog"
    }
}


#
# backup
#
resource "aws_s3_bucket" "crossbarfx-backup" {
    bucket  = var.domain-backup-bucket
    acl     = "private"
    tags    = {
        Name = "crossbarfx-backup"
    }
}
