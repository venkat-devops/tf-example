terraform {
  required_version = "~> 0.11.7"

  backend "s3" {
    key            = "networking.state"
    region         = "eu-west-2"
    dynamodb_table = "tf-statelock"
  }
}