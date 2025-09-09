# ===== KIND via OpenTofu =====
TOFU      ?= tofu
KIND_TF   ?= kind/terraform

.PHONY: kind-init kind-apply kind-plan kind-destroy kind-outputs kind-kubeconfig kind-smoke

kind-init:
	$(TOFU) -chdir=$(KIND_TF) init

kind-plan:
	$(TOFU) -chdir=$(KIND_TF) plan

kind-apply: kind-init
	$(TOFU) -chdir=$(KIND_TF) apply -auto-approve

kind-destroy:
	$(TOFU) -chdir=$(KIND_TF) destroy -auto-approve

kind-outputs:
	$(TOFU) -chdir=$(KIND_TF) output

# Надрукує готову export-команду. Підхоплює різні можливі імена output'а.
kind-kubeconfig:
	@KCFG="$$( \
		$(TOFU) -chdir=$(KIND_TF) output -raw kubeconfig 2>/dev/null || \
		$(TOFU) -chdir=$(KIND_TF) output -raw kubeconfig_path 2>/dev/null || \
		$(TOFU) -chdir=$(KIND_TF) output -raw kubeconfig_file 2>/dev/null || \
		true)"; \
	if [ -n "$$KCFG" ]; then \
		echo "export KUBECONFIG=$$KCFG"; \
	else \
		echo "❌ kubeconfig output не знайдено. Додай output у kind/terraform/outputs.tf"; exit 1; \
	fi

# Простий smoke-тест: покаже ноди KIND, використавши kubeconfig з output'а
kind-smoke:
	@export KUBECONFIG="$$( \
		$(TOFU) -chdir=$(KIND_TF) output -raw kubeconfig 2>/dev/null || \
		$(TOFU) -chdir=$(KIND_TF) output -raw kubeconfig_path 2>/dev/null || \
		$(TOFU) -chdir=$(KIND_TF) output -raw kubeconfig_file 2>/dev/null )"; \
	if [ -z "$$KUBECONFIG" ]; then echo "❌ kubeconfig output не знайдено"; exit 1; fi; \
	kubectl get nodes -o wide

# ===== GKE =====
GKE_TF_DIR := gke/terraform
TFVARS ?= $(GKE_TF_DIR)/vars.tfvars

gke-apply:
	cd $(GKE_TF_DIR) && terraform init
	cd $(GKE_TF_DIR) && terraform apply -var-file=$(TFVARS) -auto-approve

gke-destroy:
	cd $(GKE_TF_DIR) && terraform destroy -var-file=$(TFVARS) -auto-approve

gke-kubeconfig:
	cd $(GKE_TF_DIR) && terraform output -raw get_credentials_cmd | bash
