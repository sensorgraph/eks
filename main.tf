module "eks" {
  source             = "terraform-aws-modules/eks/aws"
  version            = "7.0.1"
  cluster_name       = join("-", [local.prefix_name, "pri"])
  subnets            = data.terraform_remote_state.main.outputs.public_subnet_id.*
  
  vpc_id             = data.terraform_remote_state.main.outputs.vpc_id
  
    worker_groups = [
    {
      instance_type = "t2.micro"
      asg_max_size  = 1
    }
  ]

  tags    = merge(
    var.tags,
    map("Name", join("-", [local.prefix_name, "pri"]))
  )
}
