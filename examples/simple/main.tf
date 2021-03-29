provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# helper for lookup to find account id
data "aws_caller_identity" "current" {
}

# creates the principle user to associate all these things to (not what I said it was before)
resource "aws_iam_user" "admin" {
  name = "admin"
}


module "secure-baseline" {
  source  = "nozaq/secure-baseline/aws"
  version = "0.23.1"
  # insert the 4 required variables here
  audit_log_bucket_name           = var.audit_s3_bucket_name
  aws_account_id                  = data.aws_caller_identity.current.account_id
  region                          = var.region
  support_iam_role_principal_arns = [aws_iam_user.admin.arn]

  # Setting it to true means all audit logs are automatically deleted
  #   when you run `terraform destroy`.
  # Note that it might be inappropriate for highly secured environment.
  audit_log_bucket_force_destroy = true

  providers = {
    aws                = aws
    aws.us-east-1      = aws.us-east-1
    aws.us-east-2      = aws.us-east-2
    aws.us-west-1      = aws.us-west-1
    aws.us-west-2      = aws.us-west-2
  }
}
