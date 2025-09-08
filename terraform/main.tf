terraform {
  required_version = ">= 1.6.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.0"
    }
  }
}

# ===== GitHub provider (візьме токен із env GITHUB_TOKEN) =====
provider "github" {
  owner = var.github_owner
}

# ===== KIND кластер (модуль без вхідних аргументів) =====
module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster"
}

# ===== SSH-ключ для Flux (deploy key у GitHub + приватний ключ у кластер) =====
resource "tls_private_key" "flux_git_ssh" {
  algorithm = "ED25519"
}

resource "github_repository" "flux_repo" {
  name                   = var.flux_repo # напр. "kbot-flux-infra" або "ak-kind-gke-flux-iac"
  description            = "Flux manifests and config"
  visibility             = "public" # або "public"
  auto_init              = true
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  delete_branch_on_merge = true
}

# Deploy key (дає Flux доступ по SSH до репозиторію маніфестів)
resource "github_repository_deploy_key" "flux_key" {
  repository = github_repository.flux_repo.name
  title      = "flux-deploy-key"
  key        = tls_private_key.flux_git_ssh.public_key_openssh
  read_only  = false # на етапі bootstrap потрібен запис
}

# ===== Flux provider: підключення до кластера через стандартний kubeconfig KIND =====
provider "flux" {
  kubernetes = {
    config_path = pathexpand("~/.kube/config")
  }
  git = {
    # Використовуємо значення зі змінних (а не з ресурсів), щоб не порушувати обмеження Terraform.
    url = "ssh://git@github.com/${var.github_owner}/${var.flux_repo}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux_git_ssh.private_key_openssh
    }
    branch = var.flux_branch
    path   = "flux/clusters/kind"
  }
}

# =====  bootstrap Flux у кластер + початковий коміт у Git =====
resource "flux_bootstrap_git" "this" {
  path = "flux/clusters/kind"

  # Гарантуємо порядок: спочатку KIND, repo, deploy key — потім bootstrap
  depends_on = [
    module.kind_cluster,
    github_repository.flux_repo,
    github_repository_deploy_key.flux_key
  ]
}
