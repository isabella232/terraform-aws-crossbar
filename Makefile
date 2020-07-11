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

fix:
	find . -name *.tf -exec sed -i'' 's/aws_caller_identity/crossbar-caller-identity/g' {} \;
	find . -name *.tf -exec sed -i'' 's/aws_iam_policy_document/crossbar-iam-policy-doc1/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert1/crossbar-tls-cert1/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert2/crossbar-tls-cert2/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert3/crossbar-tls-cert3/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert1_validation/crossbar-tls-cert1-validation/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert2_validation/crossbar-tls-cert2-validation/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert3_validation/crossbar-tls-cert3-validation/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar-cluster1-cpu-up-policy_scaledown/crossbar-cluster1-cpu-up-policy/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar-cluster1-cpu-up-alarm_scaledown/crossbar-cluster1-cpu-up-alarm/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_node_master/crossbar-master-node/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_keypair/crossbar-admin-keypair/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert1_validation_alt1_rec/crossbar-tls-cert1-validation-alt1/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert1_validation_cn_rec/crossbar-tls-cert1-validation-cn/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert2_validation_cn_rec/crossbar-tls-cert2-validation-cn/g' {} \;
	find . -name *.tf -exec sed -i'' 's/crossbar_dns_cert3_validation_cn_rec/crossbar-tls-cert3-validation-cn/g' {} \;
	find . -name *.tf -exec sed -i'' 's/read-crossbar-web/crossbar-web-read/g' {} \;
	find . -name *.tf -exec sed -i'' 's/public-access-crossbar-web/crossbar-web-public/g' {} \;

build:
	packer build ./crossbarfx-ami.json

version:
	docker run --rm crossbario/crossbarfx:pypy-slim-amd64 version

init:
	terraform init

plan:
	terraform plan \
		-var admin-pubkey=${HOME}/.ssh/id_rsa.pub \
		-var dns-domain-name="example.com" \
		-var domain-web-bucket="example.com-web" \
		-var domain-weblog-bucket="example.com-weblog" \
		-var domain-download-bucket="example.com-download" \
		-var domain-backup-bucket="example.com-backup"

apply:
	terraform apply \
		-var admin-pubkey=${HOME}/.ssh/id_rsa.pub \
		-var dns-domain-name="example.com"
		-var dns-domain-name="example.com" \
		-var domain-web-bucket="example.com-web" \
		-var domain-download-bucket="example.com-download" \
		-var domain-backup-bucket="example.com-backup"

destroy:
	terraform destroy \
		-var admin-pubkey=${HOME}/.ssh/id_rsa.pub \
		-var dns-domain-name="example.com"
		-var dns-domain-name="example.com" \
		-var domain-web-bucket="example.com-web" \
		-var domain-download-bucket="example.com-download" \
		-var domain-backup-bucket="example.com-backup"

refresh:
	terraform refresh \
		-var admin-pubkey=${HOME}/.ssh/id_rsa.pub \
		-var dns-domain-name="example.com"
		-var dns-domain-name="example.com" \
		-var domain-web-bucket="example.com-web" \
		-var domain-download-bucket="example.com-download" \
		-var domain-backup-bucket="example.com-backup"

list_nodes:
	ansible-inventory -i aws_ec2.yml --graph

list_scaling_group_nodes:
	aws autoscaling describe-auto-scaling-instances --region eu-central-1 --output text \
	--query "AutoScalingInstances[?AutoScalingGroupName=='crossbarfx_cluster_autoscaling'].InstanceId" \
	| xargs -n1 aws ec2 describe-instances --instance-ids ${ID} --region eu-central-1 \
	--query "Reservations[].Instances[].PrivateIpAddress" --output text

ping_nodes:
	ansible all -i aws_ec2.yml -m ping --private-key=~/.ssh/id_rsa -u ubuntu
