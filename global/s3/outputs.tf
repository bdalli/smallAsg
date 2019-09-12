output "s3_dev_env_remote_state_arn" {
  value = "${aws_s3_bucket.dev-env-remote-state.arn}"
}

output "s3_global_remote_state_arn" {
  value = "${aws_s3_bucket.global-remote-state.arn}"
}
