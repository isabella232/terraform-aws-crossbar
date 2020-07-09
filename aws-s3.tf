# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

#
# web
#
resource "aws_cloudfront_origin_access_identity" "crossbar-web" {
    comment = "crossbar-web"
}

data "aws_iam_policy_document" "read-crossbar-web-bucket" {
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

# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "crossbar-web" {
    bucket = var.domain-web-bucket
    force_destroy = true
    acl    = "public-read"

    website {
        index_document = "index.html"
    }

    logging {
        target_bucket = aws_s3_bucket.crossbar-weblog.id
        target_prefix = "web/"
    }

    tags    = {
        Name = "crossbar-web"
    }
}

resource "aws_s3_bucket_policy" "read-crossbar-web" {
    bucket = aws_s3_bucket.crossbar-web.id

    policy = data.aws_iam_policy_document.read-crossbar-web-bucket.json
}

resource "aws_s3_bucket_public_access_block" "public-access-crossbar-web" {
    bucket = aws_s3_bucket.crossbar-web.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = false
}


#
# download
#
resource "aws_cloudfront_origin_access_identity" "crossbar-download" {
    comment = "crossbar-download"
}

data "aws_iam_policy_document" "read-crossbar-download-bucket" {
    statement {
        actions   = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.crossbar-download.arn}/*"]

        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.crossbar-download.iam_arn]
        }
    }

    statement {
        actions   = ["s3:ListBucket"]
        resources = [aws_s3_bucket.crossbar-download.arn]

        principals {
            type        = "AWS"
            identifiers = [aws_cloudfront_origin_access_identity.crossbar-download.iam_arn]
        }
    }
}

resource "aws_s3_bucket" "crossbar-download" {
    bucket  = var.domain-download-bucket
    force_destroy = true
    acl    = "public-read"

    website {
        index_document = "index.html"
    }

    logging {
        target_bucket = aws_s3_bucket.crossbar-weblog.id
        target_prefix = "download/"
    }

    tags    = {
        Name = "crossbar-download"
    }
}

resource "aws_s3_bucket_policy" "read-crossbar-download" {
    bucket = aws_s3_bucket.crossbar-download.id

    policy = data.aws_iam_policy_document.read-crossbar-download-bucket.json
}

resource "aws_s3_bucket_public_access_block" "public-access-crossbar-download" {
    bucket = aws_s3_bucket.crossbar-download.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = false
}


#
# weblog
#
resource "aws_s3_bucket" "crossbar-weblog" {
    bucket  = var.domain-weblog-bucket
    force_destroy = true
    acl     = "log-delivery-write"
    tags    = {
        Name = "crossbar-weblog"
    }
}


#
# backup
#
resource "aws_s3_bucket" "crossbar-backup" {
    bucket  = var.domain-backup-bucket
    acl     = "private"
    tags    = {
        Name = "crossbar-backup"
    }
}
