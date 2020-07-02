# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

# https://www.terraform.io/docs/providers/aws/index.html
provider "aws" {
    region = var.AWS_REGION
}

resource "aws_key_pair" "crossbarfx_keypair" {
    key_name   = "crossbarfx_keypair"
    public_key = file(var.PUBKEY)
}
