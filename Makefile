TF_COMPONENT    ?= aws
TF_DIR          := ${PWD}/terraform/${TF_COMPONENT}
KMS_KEY         ?= arn:aws:kms:eu-west-3:877759700856:key/b3ac1035-b1f6-424a-bfe9-a6ec592e7487

decrypt-config:
	@sops -d config.enc.yaml > config.yaml

encrypt-config:
	@sops -e --kms ${KMS_KEY} --input-type yaml config.yaml > config.enc.yaml

decrypt-tfstate:
	@cd ${TF_DIR}; \
	sops -d terraform.tfstate.enc.json > terraform.tfstate; \
	sops -d terraform.tfstate.backup.enc.json > terraform.tfstate.backup;

encrypt-tfstate:
	@cd ${TF_DIR}; \
	sops -e --kms ${KMS_KEY} --input-type json terraform.tfstate > terraform.tfstate.enc.json; \
	sops -e --kms ${KMS_KEY} --input-type json terraform.tfstate.backup > terraform.tfstate.backup.enc.json; \
	rm terraform.tfstate terraform.tfstate.backup;

tf-init:
	@cd ${TF_DIR} && terraform init -reconfigure

tf-validate: tf-init
	@cd ${TF_DIR} && terraform validate

tf-plan:
	@cd ${TF_DIR} && terraform init -reconfigure
	@cd ${TF_DIR} && terraform plan -out=tfplan.out

tf-apply:
	@cd ${TF_DIR} && terraform apply tfplan.out

tf-destroy:
	@cd ${TF_DIR} && terraform destroy

tf-plan-enc: decrypt-config decrypt-tfstate tf-plan encrypt-tfstate

tf-apply-enc: decrypt-tfstate tf-apply encrypt-tfstate

tf-destroy-enc: decrypt-config decrypt-tfstate tf-destroy encrypt-tfstate
