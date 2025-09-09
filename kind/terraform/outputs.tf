output "kubeconfig" {
  value = pathexpand("~/.kube/config")
}