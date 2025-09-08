# ---- збираємо файли ----
locals {
  flux_src_dir = abspath("${path.module}/../flux")

  # усі yaml/yml у flux/
  flux_yaml = setunion(
    fileset(local.flux_src_dir, "**/*.yaml"),
    fileset(local.flux_src_dir, "**/*.yml")
  )

  # виключаємо службові файли bootstrap'а Flux
  flux_exclude = setunion(
    fileset(local.flux_src_dir, "clusters/*/flux-system/**"),
    fileset(local.flux_src_dir, "clusters/**/flux-system/**")
  )

  # кінцевий набір до публікації
  flux_files = setsubtract(local.flux_yaml, local.flux_exclude)
}

# ---- публікуємо кожен файл у kbot-flux-infra ----
resource "github_repository_file" "flux_tree" {
  for_each = local.flux_files

  # якщо репозиторій створюєш цим же кодом:
  repository = github_repository.flux_repo.name
  # якщо repo вже існує і ти не керуєш ним ресурсом вище:
  # repository = var.flux_repo

  branch              = var.flux_branch
  file                = "flux/${each.value}" # зберігаємо структуру
  content             = file("${local.flux_src_dir}/${each.value}")
  commit_message      = "sync: ${each.value} from ak-kind-gke-flux-iac"
  overwrite_on_create = true

  depends_on = [github_repository.flux_repo] # при потребі
}
