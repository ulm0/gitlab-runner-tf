locals {
  runner_params = {
    add_tags        = var.add_tags
    concurrency     = var.runner_concurrency
    gitlab_site     = var.gitlab_site
    gitlab_token    = var.gitlab_token
    run_untagged    = var.run_untagged
    run_as_platform = local.run_as_platform
  }
  public_key      = var.create_ssh_key ? tls_private_key.runner_key.0.public_key_openssh : file(var.public_key_path)
  private_key     = var.create_ssh_key ? tls_private_key.runner_key.0.private_key_pem : file(var.private_key_path)
  run_as_platform = var.run_as_platform == "" ? var.arch : var.run_as_platform
}
