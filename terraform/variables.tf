variable "github_owner" { type = string }
variable "flux_repo"    { type = string } # наприклад "ak-gke-flux-gitops"
variable "flux_branch"  { type = string  default = "main" }
variable "cluster_name" { type = string  default = "dev-kind" }

# для GKE (коли дійде черга)
variable "gcp_project"  { type = string  default = "ak-gke-lab-euc2" }
variable "gcp_region"   { type = string  default = "europe-central2" }
