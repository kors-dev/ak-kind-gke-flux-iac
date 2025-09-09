########################################
# outputs.tf
########################################

output "gke_cluster_name" {
  value = google_container_cluster.gke.name
}

output "gke_location" {
  value = google_container_cluster.gke.location
}

output "gke_endpoint" {
  value = google_container_cluster.gke.endpoint
}

output "kubeconfig_path" {
  value = pathexpand("~/.kube/config")
}
