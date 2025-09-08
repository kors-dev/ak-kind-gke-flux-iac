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

> Variable names in your setup may differ slightly — follow the files in `terraform/`.

## Common issues & quick fixes

### 1) `403 Resource not accessible by integration`
**Cause:** You’re using an integration `GITHUB_TOKEN` (Codespaces/GitHub App) that cannot create repositories.

**Fix:**
- Generate a **Personal Access Token (classic)** with `repo` (and `admin:org` if needed).
- Set `owner = "kors-dev"` (or your owner) in the GitHub provider.
- Re-run `tofu init` → `tofu apply`.

### 2) `422 Repository creation failed: name already exists`
**Cause:** A repository with the same name already exists.

**Options:**
- **Import** the existing repo into state:
  ```bash
  tofu import github_repository.flux_repo kors-dev/<repo-name>
  ```
- **Or** change the repo name in Terraform and `apply` again.

### 3) `node(s) already exist for a cluster with the name "kind-cluster"`
**Cause:** A kind cluster with that name already exists on your machine.

**Options:**
- Delete the existing cluster:
  ```bash
  kind get clusters
  kind delete cluster --name kind-cluster
  docker network rm kind 2>/dev/null || true
  ```
- **Or** import the existing cluster to Terraform state (if the module supports it).
- **Or** rename the cluster via module variables (set a different `name`).

## Clean up

```bash
tofu destroy
# if the cluster is still around:
kind delete cluster --name kind-cluster
```

## Next steps (Flux)

1. Install the `flux` CLI: <https://fluxcd.io/docs/installation/>
2. Use the GitHub repo prepared by this project for your manifests.
3. Bootstrap example (GitHub):
   ```bash
   flux bootstrap github \
     --owner=kors-dev \
     --repository=<your-flux-repo> \
     --branch=main \
     --path=clusters/local \
     --personal
   ```
   > If you want to use a pre-generated SSH key, pass the corresponding CLI flags or add the key in repo settings.

## Repository layout (minimal)

```
.
├── flux/                 # optional: Flux manifests/templates
└── terraform/            # OpenTofu/Terraform IaC
```

