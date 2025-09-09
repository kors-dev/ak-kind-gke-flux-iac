########################################
# providers.tf
########################################

# Google Cloud (ADC з gcloud)
provider "google" {
  project = var.project_id
  region  = var.region
}

# GitHub — потрібен для github_repository_file у sync.tf (копіювання flux/)
provider "github" {
  owner = var.github_owner
}

# Flux (GKE) — читає kubeconfig з ~/.kube/config; Git — по HTTPS + PAT
provider "flux" {
  alias = "gke"

  kubernetes = {
    # kubeconfig підтягує null_resource.gke_kubeconfig
    config_path = pathexpand("~/.kube/config")
  }

  git = {
    url = "https://github.com/${var.github_owner}/${var.flux_repo}.git"
    http = {
      username = "git"            # довільно для PAT
      password = var.github_token # передай TF_VAR_github_token
    }
    branch = var.flux_branch
    path   = "flux/clusters/gke"
  }
}
