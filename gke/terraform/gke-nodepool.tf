resource "google_container_node_pool" "np" {
  name       = "${var.name}-np"
  location   = var.zone
  cluster    = google_container_cluster.gke.name
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    labels       = { env = "dev" }
    tags         = ["gke-node"]
    metadata     = { disable-legacy-endpoints = "true" }
  }
}
