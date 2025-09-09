########################################
# variables.tf
########################################

# ---- GKE базові ----
variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-central2"
}

variable "zone" {
  type    = string
  default = "europe-central2-a"
}

variable "name" {
  type    = string
  default = "ak-gke"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

# ---- Мережа ----
variable "network" {
  type    = string
  default = "default"
}

variable "subnetwork" {
  type    = string
  default = "default"
}

# ---- GitHub / Flux ----
variable "github_owner" {
  type = string
}

variable "flux_repo" {
  type    = string
  default = "kbot-flux-infra"
}

variable "flux_branch" {
  type    = string
  default = "main"
}

variable "github_token" {
  type      = string
  sensitive = true
}

# Шлях до локального каталогу з GitOps-маніфестами.
# ФУНКЦІЙ тут НЕ використовуємо. Порожнє означає: порахуємо у locals (див. sync.tf).
variable "flux_src_dir" {
  type    = string
  default = ""
}
