# ===== KIND =====
KIND_DIR := kind/terraform
KIND_NAME ?= kind-cluster

kind-up:
	kind create cluster --name $(KIND_NAME) --config $(KIND_DIR)/kind-cluster-config
	kubectl cluster-info --context kind-$(KIND_NAME)

kind-apply:
	kubectl apply -f $(KIND_DIR)

kind-clean:
	kubectl delete -f $(KIND_DIR) || true

kind-down:
	kind delete cluster --name $(KIND_NAME)

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
