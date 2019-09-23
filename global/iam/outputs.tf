# output "s3_tf_role_arn" {
#   value = "${aws_iam_role.tf_state_role.arn}"
# }

output "tf_remote_user_arn" {
  value = "${aws_iam_user.tf_remote.arn}"
}

output "packer_policy_arn" {
  value = "${aws_iam_policy.packer-policy.arn}"

}

output "packer_profile_name" {
  value = "${aws_iam_instance_profile.ec2_packer.name}"

}


output "packer_policy_name" {
  value = "${aws_iam_policy.packer-policy.name}"
}
