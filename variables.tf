# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

variable "AWS_REGION" {
    default = "eu-central-1"
}

variable "AMIS" {
    type = map(string)
    default = {
        eu-central-1 = "ami-06ca2353bcdf3ac29"
    }
}

variable "PUBKEY" {
    type = string
}

variable "PRIVKEY" {
    type = string
}

variable "DOMAIN_ID" {
    type = string
}

variable "DOMAIN_NAME" {
    type = string
}
