# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

variable "AWS_REGION" {
    default = "eu-central-1"
}

variable "AWS_AZ" {
    default = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "AMIS" {
    type = map(string)
    default = {
        eu-central-1 = "ami-06ca2353bcdf3ac29"
    }
}

variable "INSTANCE_TYPE" {
    default = "t3a.medium"
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
