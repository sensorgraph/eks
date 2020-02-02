provider "aws" {
  region  = data.terraform_remote_state.main.outputs.region
  version = "~> 2.47.0"
}

terraform {
  backend "s3" {
    bucket = "tfstate.kibadex.net"
    key    = "kubernetes/terraform.tfstate"
    region = "eu-west-3"
  }
}
