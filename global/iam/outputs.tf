# output "s3_tf_role_arn" {
#   value = "${aws_iam_role.tf_state_role.arn}"
# }

output "tf_remote_user_arn" {
  value = "${aws_iam_user.tf_remote.arn}"
}

output "packer_policy_arn" {
  value = "${aws_iam_policy.packer-policy.arn}"

}

