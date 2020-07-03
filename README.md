# Terraform based setup of Crossbar.io FX

This provides a Terraform module that can create clusters of Crossbar.io FX in AWS.
The module will define all necessary resources based on the [Terraform Provider for AWS](https://terraform.io/docs/providers/aws/index.html).

## Usage

The following will create and deploy a Crossbar.io FX based cluster in AWS with two edge nodes and one master node.

First, create a new Terraform workspace and a file `main.tf`

```console
cd myenv1
main.tf
```

with this contents:

```hcl
module "crossbarfx" {
    source  = "crossbario/crossbarfx/aws"
    version = "1.1.0"

    # your SSH key
    PUBKEY = "~/.ssh/id_rsa.pub"

    # where to deploy to
    AWS_REGION = "eu-central-1"
    AWS_AZ = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

    # what instance type to use (for both master and edge nodes)
    INSTANCE_TYPE = "t3a.medium"

    # for which DNS domain to host
    DOMAIN_NAME = "tentil.es"
    DOMAIN_ID = "tentiles"

    # setup TLS certificates and all that (note: this can only be activated
    # once the domain nameservers do work)
    ENABLE_TLS = false
}
```

> Adjust `DOMAIN_NAME` and `DOMAIN_ID` (at least) in above.

Now initialize your workspace

```console
terraform init
```

and plan and apply your deployment

```console
terraform plan
terraform apply
```
