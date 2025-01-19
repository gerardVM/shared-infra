TF_COMPONENT    ?= aws
TF_DIR          := ${PWD}/terraform/${TF_COMPONENT}
AWS_ACCOUNT     ?= account_0
TF_STATE_DIR    := ${TF_DIR}/terraform.tfstate.d/${AWS_ACCOUNT}

-include Makefile.local

decrypt-configs:
	@for file in *.enc.yaml; do \
		base=$$(basename $$file .enc.yaml); \
		sops -d $$file > "$${base}.yaml"; \
	done

encrypt-configs:
	@for file in *.yaml; do \
		case $$file in \
			*.enc.yaml) continue ;; \
		esac; \
		base=$$(basename $$file .yaml); \
		sops -e --kms ${KMS_KEY} --input-type yaml $$file > "$${base}.enc.yaml"; \
	done

decrypt-tfstate:
	@cd ${TF_STATE_DIR}; \
	sops -d terraform.tfstate.enc.json > terraform.tfstate; \
	sops -d terraform.tfstate.backup.enc.json > terraform.tfstate.backup;

encrypt-tfstate:
	@cd ${TF_STATE_DIR}; \
	sops -e --kms ${KMS_KEY} --input-type json terraform.tfstate > terraform.tfstate.enc.json; \
	sops -e --kms ${KMS_KEY} --input-type json terraform.tfstate.backup > terraform.tfstate.backup.enc.json; \
	rm terraform.tfstate terraform.tfstate.backup;

tf-workspace:
	@cd ${TF_DIR} && terraform workspace select ${AWS_ACCOUNT}

tf-init:
	@cd ${TF_DIR} && terraform init -reconfigure

tf-plan: tf-init tf-workspace
	@cd ${TF_DIR} && terraform plan -var="config=$(AWS_ACCOUNT).yaml" -out=${AWS_ACCOUNT}.out

tf-apply:
	@cd ${TF_DIR} && terraform apply ${AWS_ACCOUNT}.out

tf-destroy:
	@cd ${TF_DIR} && terraform destroy

tf-plan-enc: decrypt-configs decrypt-tfstate tf-plan encrypt-tfstate

tf-apply-enc: decrypt-tfstate tf-apply encrypt-tfstate

tf-destroy-enc: decrypt-configs decrypt-tfstate tf-destroy encrypt-tfstate
