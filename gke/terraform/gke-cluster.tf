########################################
# gke-cluster.tf
########################################

# Увімкнути Kubernetes API
resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}

# Регіональний кластер GKE (для зонального постав location = var.zone)
resource "google_container_cluster" "gke" {
  name     = var.name
  location = var.region

  # Підв'язуємося до створених VPC/сабнету
  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  remove_default_node_pool = true
  initial_node_count       = 1
  release_channel { channel = "REGULAR" }
  networking_mode = "VPC_NATIVE"

  # Використати secondary діапазони з сабнету
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name # pods
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name # services
  }

  depends_on = [google_project_service.container]
}

# Підтягнути kubeconfig через gcloud (для провайдера Flux)
resource "null_resource" "gke_kubeconfig" {
  triggers = {
    cluster = google_container_cluster.gke.name
    region  = var.region
  }

  provisioner "local-exec" {
    command     = "gcloud container clusters get-credentials ${google_container_cluster.gke.name} --region ${var.region}"
    environment = { USE_GKE_GCLOUD_AUTH_PLUGIN = "True" }
  }

  depends_on = [google_container_node_pool.default]
}
