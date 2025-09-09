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

variable "cluster_name" {
  type    = string
  default = "dev-kind"
}