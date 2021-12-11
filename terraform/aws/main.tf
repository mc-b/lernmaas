#######
#
#   AWS Cloud


# VM in AWS

module "aws" {
  source     = "./modules/aws"
  module     = var.module
  ports      = var.ports
  public_key = var.public_key
  enabled    = var.aws
}
