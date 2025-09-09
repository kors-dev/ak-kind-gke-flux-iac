terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google      = { source = "hashicorp/google",      version = "~> 5.0" }
    google-beta = { source = "hashicorp/google-beta", version = "~> 5.0" }
  }
  # (опц.) бекенд у GCS:
  # backend "gcs" {
  #   bucket = "ak-gke-flux-gitops-tfstate"
  #   prefix = "gke"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}
