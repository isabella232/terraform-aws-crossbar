# Copyright (c) Crossbar.io Technologies GmbH. Licensed under GPL 3.0.

default:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "  build        Build AMI using Packer."
	@echo "  version      Print version from Docker image."
	@echo "  plan         Plan Terraform deployment."
	@echo "  apply        Apply Terraform deployment."
	@echo "  destroy      Destroy Terraform deployment."
	@echo "  refresh      Refresh Terraform deployment."
	@echo "  list_nodes   List all nodes in auto-scaling group (core/edge nodes, not master)."
	@echo "  ping_nodes   Ping all nodes in auto-scaling group (will SSH into the instances)."
	@echo ""

build:
	packer build ./crossbarfx-ami.json

version:
	docker run --rm crossbario/crossbarfx:pypy-slim-amd64 version

init:
	terraform init \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="example.com" \
		-var DOMAIN_ID="examplecom"

plan:
	terraform plan \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="example.com" \
		-var DOMAIN_ID="examplecom"

apply:
	terraform apply \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="example.com" \
		-var DOMAIN_ID="examplecom"

destroy:
	terraform destroy \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="example.com" \
		-var DOMAIN_ID="examplecom"

refresh:
	terraform refresh \
		-var PUBKEY=${HOME}/.ssh/id_rsa.pub \
		-var DOMAIN_NAME="example.com" \
		-var DOMAIN_ID="examplecom"

list_nodes:
	ansible-inventory -i aws_ec2.yml --graph

list_scaling_group_nodes:
	aws autoscaling describe-auto-scaling-instances --region eu-central-1 --output text \
	--query "AutoScalingInstances[?AutoScalingGroupName=='crossbarfx_cluster_autoscaling'].InstanceId" \
	| xargs -n1 aws ec2 describe-instances --instance-ids ${ID} --region eu-central-1 \
	--query "Reservations[].Instances[].PrivateIpAddress" --output text

ping_nodes:
	ansible all -i aws_ec2.yml -m ping --private-key=~/.ssh/id_rsa -u ubuntu
