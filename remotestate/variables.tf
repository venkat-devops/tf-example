variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "region" {
  default = "eu-west-2"
}

variable "replication_region" {
  default = "eu-west-2"
}

variable "networking_bucket" {
  default = "networking-tfstate-1675"
}

variable "application_bucket" {
  default = "applications-tfstate-1675"
}

variable "default_user" {
  default = ""
}

variable "dynamodb_table" {
  default = "tf-statelock"
}
