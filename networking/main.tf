terraform {
  required_version = "~> 0.11.7"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "eu-west-2"
}

resource "aws_eip" "my_eip" {
  vpc = "true"
}
