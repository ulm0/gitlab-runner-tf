variable "name" {
  type    = string
  default = ""
}
variable "add_tags" {
  type    = bool
  default = true
}
variable "arch" {
  type    = string
  default = "arm64"
}
# variable "bootscript_name_filter" {}
variable "gitlab_site" {
  type    = string
  default = "https://gitlab.com/"
}
variable "gitlab_token" {
  type    = string
  default = "XXXXXXXX"
}
variable "run_untagged" { default = false }
variable "runner_concurrency" { default = 2 }
# variable "server_type" {}
variable "instance_type" {
  type    = string
  default = "c6g.medium"
}
variable "create_ssh_key" {
  type    = bool
  default = true
}
variable "public_key_path" {
  type    = string
  default = ""
}
variable "private_key_path" {
  type    = string
  default = ""
}
variable "run_as_platform" {
  type        = string
  default     = ""
  description = "Specify a platform to execute the runner as"
}
