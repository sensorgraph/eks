resource "aws_iam_policy" "secretsmanager" {
  name   = join("-", [local.prefix_name, "pri", "pol", "sct"])
  policy = data.template_file.secretsmanager.rendered
}