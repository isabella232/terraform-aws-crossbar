# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "crossbarfx-web" {
    bucket  = var.domain-web-bucket
    acl     = "public"

    website {
        index_document = "index.html"
        error_document = "error.html"
    }

    logging {
        target_bucket = aws_s3_bucket.crossbarfx-weblog.id
    }

    versioning {
        enabled = true
    }

    tags    = {
        Name = "crossbarfx-web"
    }
}

resource "aws_s3_bucket" "crossbarfx-weblog" {
    bucket  = var.domain-weblog-bucket
    acl     = "private"
    tags    = {
        Name = "crossbarfx-weblog"
    }
}

resource "aws_s3_bucket" "crossbarfx-download" {
    bucket  = var.domain-download-bucket
    acl     = "public"
    tags    = {
        Name = "crossbarfx-download"
    }
}

resource "aws_s3_bucket" "crossbarfx-backup" {
    bucket  = var.domain-backup-bucket
    acl     = "private"
    tags    = {
        Name = "crossbarfx-backup"
    }
}
