terraform {
  required_version = "~> 0.11.7"
}

provider "aws" {
  version = "~> 1.16.0"
  #region  = "${var.region}"
  region = "eu-west-2"
  alias   = "primary"
}

provider "aws" {
  version = "~> 1.16.0"
  region  = "${var.replication_region}"
  alias   = "replication"
}

data "template_file" "application_bucket_policy" {
  template = "${file("templates/bucket_policy.tpl")}"

  vars {
    read_only_user_arn   = "${aws_iam_user.networking.arn}"
    full_access_user_arn = "${aws_iam_user.application.arn}"
    s3_bucket            = "${var.application_bucket}"
  }
}

data "template_file" "networking_bucket_policy" {
  template = "${file("templates/bucket_policy.tpl")}"

  vars {
    read_only_user_arn   = "${aws_iam_user.application.arn}"
    full_access_user_arn = "${aws_iam_user.networking.arn}"
    s3_bucket            = "${var.networking_bucket}"
  }
}

data "template_file" "application_user_policy" {
  template = "${file("templates/user_policy.tpl")}"

  vars {
    s3_ro_bucket       = "${var.networking_bucket}"
    s3_rw_bucket       = "${var.application_bucket}"
    dynamodb_table_arn = "${aws_dynamodb_table.tf_statelock.arn}"
  }
}

data "template_file" "networking_user_policy" {
  template = "${file("templates/user_policy.tpl")}"

  vars {
    s3_ro_bucket       = "${var.application_bucket}"
    s3_rw_bucket       = "${var.networking_bucket}"
    dynamodb_table_arn = "${aws_dynamodb_table.tf_statelock.arn}"
  }
}

resource "aws_dynamodb_table" "tf_statelock" {
  name           = "${var.dynamodb_table}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "ddtnet" {
  bucket        = "${var.networking_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = "${data.template_file.networking_bucket_policy.rendered}"
}

resource "aws_s3_bucket" "ddtapp" {
  bucket        = "${var.application_bucket}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  policy = "${data.template_file.application_bucket_policy.rendered}"
}

resource "aws_iam_user" "application" {
  name = "application"
}

resource "aws_iam_access_key" "application" {
  user = "${aws_iam_user.application.name}"
}

resource "aws_iam_user_policy" "application_rw" {
  name = "application"
  user = "${aws_iam_user.application.name}"

  policy = "${data.template_file.application_user_policy.rendered}"
}

resource "aws_iam_user" "networking" {
  name = "networking"
}

resource "aws_iam_access_key" "netwokring" {
  user = "${aws_iam_user.networking.name}"
}

resource "aws_iam_user_policy" "networking_rw" {
  name = "networking"
  user = "${aws_iam_user.networking.name}"

  policy = "${data.template_file.networking_user_policy.rendered}"
}

resource "aws_iam_user" "cicd" {
  name = "jenkins"
}

resource "aws_iam_access_key" "cicd" {
  user = "${aws_iam_user.cicd.name}"
}

resource "aws_iam_user_policy_attachment" "cicd_policy" {
  user       = "${aws_iam_user.cicd.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group" "rdsadmin" {
  name = "RDSAdmin"
}

resource "aws_iam_group_policy_attachment" "rdsadmin_attach" {
  group      = "${aws_iam_group.rdsadmin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_group" "ec2admin" {
  name = "EC2Admin"
}

resource "aws_iam_group_policy_attachment" "ec2admin_attach" {
  group      = "${aws_iam_group.ec2admin.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_membership" "add_ec2admin" {
  name = "add_ec2admin"

  users = [
    "${aws_iam_user.networking.name}",
    "${aws_iam_user.application.name}",
  ]

  group = "${aws_iam_group.ec2admin.name}"
}

resource "aws_iam_group_membership" "add_rdsadmin" {
  name = "add_rdsadmin"

  users = [
    "${aws_iam_user.application.name}",
  ]

  group = "${aws_iam_group.rdsadmin.name}"
}
