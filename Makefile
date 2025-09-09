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

# ===== GKE via OpenTofu =====
TOFU      ?= tofu
GKE_TF    ?= gke/terraform
TFVARS    ?= $(GKE_TF)/vars.tfvars

gke-init:
	$(TOFU) -chdir=$(GKE_TF) init -upgrade

gke-plan:
	@if [ -f $(TFVARS) ]; then \
	  $(TOFU) -chdir=$(GKE_TF) plan -var-file=$(TFVARS); \
	else \
	  $(TOFU) -chdir=$(GKE_TF) plan; \
	fi

gke-apply: gke-init
	@if [ -f $(TFVARS) ]; then \
	  TF_VAR_github_token="$$GITHUB_TOKEN" $(TOFU) -chdir=$(GKE_TF) apply -auto-approve -var-file=$(TFVARS); \
	else \
	  TF_VAR_github_token="$$GITHUB_TOKEN" $(TOFU) -chdir=$(GKE_TF) apply -auto-approve; \
	fi

gke-destroy:
	@if [ -f $(TFVARS) ]; then \
	  $(TOFU) -chdir=$(GKE_TF) destroy -auto-approve -var-file=$(TFVARS); \
	else \
	  $(TOFU) -chdir=$(GKE_TF) destroy -auto-approve; \
	fi

gke-outputs:
	$(TOFU) -chdir=$(GKE_TF) output

# Отримати kubeconfig для кластера (регіональний або зональний)
gke-kubeconfig:
	@export USE_GKE_GCLOUD_AUTH_PLUGIN=True; \
	CLUSTER="$$( $(TOFU) -chdir=$(GKE_TF) output -raw gke_cluster_name )"; \
	LOC="$$( $(TOFU) -chdir=$(GKE_TF) output -raw gke_location 2>/dev/null || true )"; \
	if [ -z "$$CLUSTER" ]; then echo "❌ output gke_cluster_name не знайдено"; exit 1; fi; \
	if echo "$$LOC" | grep -Eq '^[a-z]+-[a-z]+[0-9]+$$'; then \
	  echo "→ gcloud container clusters get-credentials $$CLUSTER --region $$LOC"; \
	  gcloud container clusters get-credentials $$CLUSTER --region $$LOC; \
	else \
	  echo "→ gcloud container clusters get-credentials $$CLUSTER --zone $$LOC"; \
	  gcloud container clusters get-credentials $$CLUSTER --zone $$LOC; \
	fi
