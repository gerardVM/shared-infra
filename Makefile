TF_COMPONENT    ?= aws
TF_DIR          := ${PWD}/terraform/${TF_COMPONENT}
ENCRYPTED       ?= false
KMS_KEY         ?= arn:aws:kms:eu-west-3:877759700856:key/b3ac1035-b1f6-424a-bfe9-a6ec592e7487

decrypt-config:
	@if [ ${ENCRYPTED} = true ]; then sops -d config.enc.yaml > config.yaml; fi

encrypt-config:
	@sops -e --kms ${KMS_KEY} --input-type yaml config.yaml > config.enc.yaml

decrypt-tfstate:
	@if [ ${ENCRYPTED} = true ]; then \
		cd ${TF_DIR}; \
		sops -d terraform.tfstate.enc.json > terraform.tfstate; \
		sops -d terraform.tfstate.backup.enc.json > terraform.tfstate.backup; \
	fi

encrypt-tfstate:
	@if [ ${ENCRYPTED} = true ]; then \
		cd ${TF_DIR}; \
		sops -e --kms ${KMS_KEY} --input-type json terraform.tfstate > terraform.tfstate.enc.json; \
		sops -e --kms ${KMS_KEY} --input-type json terraform.tfstate.backup > terraform.tfstate.backup.enc.json; \
		rm terraform.tfstate terraform.tfstate.backup; \
	fi

tf-init:
	@cd ${TF_DIR} && terraform init -reconfigure

tf-validate: tf-init
	@cd ${TF_DIR} && terraform validate


tf-plan-unenc: decrypt-config
	@cd ${TF_DIR} && terraform init -reconfigure
	@cd ${TF_DIR} && terraform plan -out=tfplan.out

tf-plan: decrypt-tfstate tf-plan-unenc encrypt-tfstate


tf-apply-unenc:
	@cd ${TF_DIR} && terraform apply tfplan.out

tf-apply: decrypt-tfstate tf-apply-unenc encrypt-tfstate


tf-output-unenc:
	@cd ${TF_DIR} && terraform output -json

tf-output: decrypt-tfstate tf-output-unenc encrypt-tfstate


tf-import-unenc:
	@cd ${TF_DIR} && terraform import ${TF_RESOURCE} ${TF_ID}

tf-import: decrypt-tfstate tf-import-unenc encrypt-tfstate


tf-destroy-unenc:
	@cd ${TF_DIR} && terraform destroy

tf-destroy: decrypt-tfstate tf-destroy-unenc encrypt-tfstate


tf-deploy: tf-plan tf-apply