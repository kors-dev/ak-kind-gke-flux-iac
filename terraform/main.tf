terraform {
  required_version = ">= 1.6.0"
  required_providers {
    github = { source = "integrations/github" version = "~> 6.0" }
    tls    = { source = "hashicorp/tls"      version = "~> 4.0" }
    flux   = { source = "fluxcd/flux"        version = "~> 1.0" }
  }
}

provider "github" {
  owner = var.github_owner
  # токен бере з env GITHUB_TOKEN
}

# 4.1 KIND кластер
module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster"
  name   = var.cluster_name
}

# 4.2 SSH ключ для Flux deploy key
resource "tls_private_key" "flux_git_ssh" {
  algorithm = "ED25519"
}

# 4.3 Створення/підготовка репо з маніфестами (можна пропустити, якщо repo вже є)
module "flux_repo" {
  source         = "github.com/den-vasyliev/tf-github-repository"
  name           = var.flux_repo
  description    = "Flux manifests and config"
  visibility     = "private"
  auto_init      = true
  default_branch = var.flux_branch
}

# 4.4 Deploy key для Flux
resource "github_repository_deploy_key" "flux_key" {
  repository = var.flux_repo
  title      = "flux-deploy-key"
  key        = tls_private_key.flux_git_ssh.public_key_openssh
  read_only  = false
}

# 4.5 Flux bootstrap у KIND
provider "flux" {
  kubernetes = {
    host                   = module.kind_cluster.kubeconfig.host
    cluster_ca_certificate = module.kind_cluster.kubeconfig.cluster_ca_certificate
    client_certificate     = module.kind_cluster.kubeconfig.client_certificate
    client_key             = module.kind_cluster.kubeconfig.client_key
  }
  git = {
    url = "ssh://git@github.com/${var.github_owner}/${var.flux_repo}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux_git_ssh.private_key_openssh
    }
    branch = var.flux_branch
    path   = "flux/clusters/kind"
  }
}

resource "flux_bootstrap_git" "this" {
  path = "flux/clusters/kind"
}

# опційно: вивести kubeconfig path
output "kubeconfig" {
  value = module.kind_cluster.kubeconfig_path
}
