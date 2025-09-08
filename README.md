# ak-kind-gke-flux-iac

Infrastructure-as-Code (IaC) to spin up a **local Kubernetes cluster with KIND** and prepare a **GitHub repository** for **Flux GitOps**. The project keeps things simple and explicit: it generates an SSH key, creates/uses a GitHub repo, brings up a `kind` cluster — then you drive everything via Git.

> Straight talk: this is a starter skeleton for GitOps on a local cluster. Minimal magic, maximum transparency.

```
+-------------------+         tofu apply          +---------------------------+
|   local machine   |  ------------------------>  |  KIND cluster (kind-...)  |
|   Docker + kind   |                              |  kube-system, flux-system |
+-------------------+                              +---------------------------+
         |                                                     ^
         | generates SSH                                       |
         v                                                     |
+---------------------------+        creates/uses              |
|  GitHub repository        | <--------------------------------+
|  (for Flux manifests)     |
+---------------------------+
```

## What this project does

- **Generates an SSH key** for Flux-to-git access (Terraform `tls_private_key`).
- **Creates a KIND cluster** with a fixed name (default: `kind-cluster`).
- **Creates or picks up a GitHub repository** for your GitOps manifests (Terraform `github_repository`).

> You can extend this to GKE later. This repo focuses on a local KIND flow and GitOps repository preparation.

## Requirements

- **Docker** (for KIND)
- **kubectl**
- **kind**
- **OpenTofu / Terraform** (`tofu` CLI)
- **GitHub Personal Access Token (classic)** with `repo` scope  
  Export it as `GITHUB_TOKEN` (see below). If using an organization repo, you may also need `admin:org`.

## Quick start

```bash
git clone https://github.com/kors-dev/ak-kind-gke-flux-iac.git
cd ak-kind-gke-flux-iac/terraform

# 1) GitHub token (classic PAT with repo; add admin:org for org repos)
export GITHUB_TOKEN=<your-classic-pat>

# 2) Prep
tofu fmt -recursive
tofu init -upgrade
tofu validate

# 3) Apply
tofu apply
```

Check the cluster:
```bash
kubectl cluster-info
kubectl get nodes -o wide
```

## Providers & variables

- The GitHub provider must know your **owner** (user/org). Example:
  ```hcl
  provider "github" {
    owner = "kors-dev"
    # optional: token = var.github_token  # or rely on ENV GITHUB_TOKEN
  }
  ```
- It’s convenient to pass the token via environment variable:
  ```bash
  export GITHUB_TOKEN=<classic-pat>
  # or
  export TF_VAR_github_token="$GITHUB_TOKEN"
  ```

  ```bash
    export TELEGRAM_BOT_TOKEN='<your telegram bot token>'
    kubectl -n default create secret generic kbot --from-literal=token="$TELEGRAM_BOT_TOKEN"
  ```
> Variable names in your setup may differ slightly — follow the files in `terraform/`.

## Clean up

```bash
tofu destroy
# if the cluster is still around:
kind delete cluster --name kind-cluster
```