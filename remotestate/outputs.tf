output "application_access_key" {
  value = "${aws_iam_access_key.application.id}"
}

output "application_secret_key" {
  value = "${aws_iam_access_key.application.secret}"
}

output "networking_access_key" {
  value = "${aws_iam_access_key.netwokring.id}"
}

output "networking_secret_key" {
  value = "${aws_iam_access_key.netwokring.secret}"
}

output "cicd_access_key" {
  value = "${aws_iam_access_key.cicd.id}"
}

output "cicd_secret_key" {
  value = "${aws_iam_access_key.cicd.secret}"
}
