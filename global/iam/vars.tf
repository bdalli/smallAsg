# env vars
#variable "env_name" {}
variable "aws_region" {
  type    = "string"
  default = "eu-west-1"
}

variable "dev-env-remote-state" {
  type    = "string"
  default = "dev-env-remote-state"
}
