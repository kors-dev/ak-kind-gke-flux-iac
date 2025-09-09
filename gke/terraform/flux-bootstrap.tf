resource "flux_bootstrap_git" "gke" {
  provider   = flux.gke
  path       = "flux/clusters/gke"
  depends_on = [null_resource.gke_kubeconfig]
}
