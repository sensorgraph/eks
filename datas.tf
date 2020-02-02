# Reference : https://github.com/sensorgraph/infra
data "terraform_remote_state" "main" {
  backend = "s3"
  config = {
    bucket = "tfstate.kibadex.net"
    key    = "infra/terraform.tfstate"
    region = "eu-west-3"
  }
}

data "terraform_remote_state" "bastion" {
  backend = "s3"
  config = {
    bucket = "tfstate.kibadex.net"
    key    = "bastion/terraform.tfstate"
    region = "eu-west-3"
  }
}

data "aws_caller_identity" "current" {}

data "aws_ami" "main" {
  most_recent  = true
  owners = ["amazon"]

    filter {
    name   = "name"
    values = ["amazon-eks-node-1.14-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#IAM Policy

data "template_file" "secretsmanager" {
  template = file("files/iam/secretsmanager-policy.json.tpl")
  vars     = {
            secretsmanager_arn = "arn:aws:secretsmanager:${data.terraform_remote_state.main.outputs.region}:${data.aws_caller_identity.current.account_id}:secret:/cicd/*"
          }
}

# KMS keys
data "aws_kms_alias" "lambda" {
  name = "alias/aws/lambda"
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_kms_alias" "sqs" {
  name = "alias/aws/sqs"
}

data "aws_kms_alias" "dynamodb" {
  name = "alias/aws/dynamodb"
}