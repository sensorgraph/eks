resource "tls_private_key" "main" {
  algorithm   = "RSA"
}

resource "aws_key_pair" "main" {
  key_name   = join("-", [local.prefix_name, "pri"])
  public_key = tls_private_key.main.public_key_openssh
}

resource "aws_secretsmanager_secret" "main" {
  name                    = join("-", [local.prefix_name, "pri"])
  recovery_window_in_days = 0
  description             = "[Terraform] SSH root key for eks cluster"
  tags                    = merge(var.tags, map("Name", join("-", [local.prefix_name, "pri"])))
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id     = aws_secretsmanager_secret.main.id
  secret_string = jsonencode(merge(map("keypair", tls_private_key.main.private_key_pem)))
}

module "eks" {
  source             = "terraform-aws-modules/eks/aws"
  version            = "7.0.1"
  cluster_name       = join("-", [local.prefix_name, "pri"])
  subnets            = data.terraform_remote_state.main.outputs.private_subnet_id.*
  
  vpc_id             = data.terraform_remote_state.main.outputs.vpc_id
  
  worker_groups = [
    {
      instance_type = "t2.medium"
      asg_max_size  = 1
      key_name      = aws_key_pair.main.key_name
    }
  ]

  worker_additional_security_group_ids = [
    data.terraform_remote_state.bastion.outputs.ssh_sg_id
  ]

  workers_additional_policies = [
    data.aws_iam_policy.secretsmanager.arn
  ]

  tags    = merge(
    var.tags,
    map("Name", join("-", [local.prefix_name, "pri"]))
  )
}
