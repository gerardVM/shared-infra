TF_COMPONENT ?= aws
AWS_ACCOUNT  ?= account_0
TF_DIR       := ${PWD}/terraform/${TF_COMPONENT}
TF_STATE_DIR := ${TF_DIR}/terraform.tfstate.d/${AWS_ACCOUNT}

export ${KMS_KEY}

-include Makefile.local

decrypt-configs:
	@for file in ${TF_DIR}/*.yaml; do \
		base=$$(basename $$file .yaml); \
		sops -d $$file > "$${base}.dec.yaml"; \
	done

encrypt-configs:
	@for file in *.dec.yaml; do \
		base=$$(basename $$file .dec.yaml); \
		sops -e --kms ${KMS_KEY} --input-type yaml $$file > "${TF_DIR}/$${base}.yaml"; \
	done

merge-configs:
	@mkdir -p ${TF_DIR}/.terraform
	@for file in *.dec.yaml; do \
		case $$file in \
			all_accounts.dec.yaml) continue ;; \
		esac; \
		base=$$(basename $$file .dec.yaml); \
		yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' $$file all_accounts.dec.yaml > ${TF_DIR}/.terraform/$${base}.yaml; \
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

tf-workspace-create:
	@cd ${TF_DIR} && terraform workspace new ${AWS_ACCOUNT}

tf-workspace-select:
	@cd ${TF_DIR} && terraform workspace select ${AWS_ACCOUNT}

tf-init:
	@cd ${TF_DIR} && terraform init -reconfigure

tf-plan: merge-configs tf-init tf-workspace-select
	@cd ${TF_DIR} && terraform plan -var="config=$(AWS_ACCOUNT).yaml" -out=${AWS_ACCOUNT}.out

tf-apply:
	@cd ${TF_DIR} && terraform apply ${AWS_ACCOUNT}.out

tf-destroy:
	@cd ${TF_DIR} && terraform destroy

tf-plan-enc: decrypt-configs decrypt-tfstate tf-plan encrypt-tfstate

tf-apply-enc: decrypt-tfstate tf-apply encrypt-tfstate

tf-destroy-enc: decrypt-configs decrypt-tfstate tf-destroy encrypt-tfstate
