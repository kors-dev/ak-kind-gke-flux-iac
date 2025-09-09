########################################
# variables.tf
########################################

# GKE базові
variable "project_id"   { type = string }
variable "region"       { type = string  default = "europe-central2" }
variable "zone"         { type = string  default = "europe-central2-a" }
variable "name"         { type = string  default = "ak-gke" }
variable "node_count"   { type = number  default = 1 }
variable "machine_type" { type = string  default = "e2-standard-2" }

# GitHub / Flux
variable "github_owner" { type = string }                          # напр. "kors-dev"
variable "flux_repo"    { type = string  default = "kbot-flux-infra" }
variable "flux_branch"  { type = string  default = "main" }
variable "github_token" { type = string  sensitive = true }        # TF_VAR_github_token

# (необов’язково) якщо хочеш параметризувати шлях до локального flux/ у sync.tf
variable "flux_src_dir" {
  type    = string
  default = abspath("${path.module}/../../flux")
}
