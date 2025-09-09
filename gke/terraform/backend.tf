terraform {
  backend "gcs" {
    bucket = "ak-gke-flux-tfstate"
    prefix = "gke"
  }
}
