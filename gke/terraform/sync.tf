########################################
# sync.tf
########################################

locals {
  # якщо var.flux_src_dir заданий — використовуємо його,
  # інакше беремо ../../flux від поточного модуля
  flux_src_dir = var.flux_src_dir != "" ? var.flux_src_dir : abspath("${path.module}/../../flux")

  flux_yaml = setunion(
    fileset(local.flux_src_dir, "**/*.yaml"),
    fileset(local.flux_src_dir, "**/*.yml")
  )

  flux_exclude = setunion(
    fileset(local.flux_src_dir, "clusters/*/flux-system/**"),
    fileset(local.flux_src_dir, "clusters/**/flux-system/**")
  )

  flux_files = setsubtract(local.flux_yaml, local.flux_exclude)
}

resource "github_repository_file" "flux_tree" {
  for_each            = local.flux_files
  repository          = var.flux_repo
  branch              = var.flux_branch
  file                = "flux/${each.value}"
  content             = file("${local.flux_src_dir}/${each.value}")
  commit_message      = "sync(gke): ${each.value} from ak-kind-gke-flux-iac"
  overwrite_on_create = true
}
