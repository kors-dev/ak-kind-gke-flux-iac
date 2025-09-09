########################################
# gke-nodepool.tf
########################################

resource "google_container_node_pool" "default" {
  name     = "np-default"
  location = var.region # якщо кластер зональний — постав var.zone
  cluster  = google_container_cluster.gke.name

  # Фіксований розмір пулу; хочеш автоскейл — заміни на блок autoscaling{}
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50

    # Для демо ок; у проді краще Workload Identity
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = { role = "apps" }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
