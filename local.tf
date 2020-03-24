locals {
  runner_params = {
    add_tags     = var.add_tags
    concurrency  = var.runner_concurrency
    gitlab_site  = var.gitlab_site
    gitlab_token = var.gitlab_token
  }
}
