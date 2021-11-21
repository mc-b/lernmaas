#######
#
#   Root - vereint alle anderen Module 

# Git Repository


# VM in AWS

module "aws" {
  source     = "./modules/aws"
  module     = var.module
  ports      = var.ports
  public_key = var.public_key
  enabled    = var.aws
}

# VM in Azure

module "azure" {
  source     = "./modules/azure"
  module     = var.module
  ports      = var.ports
  public_key = var.public_key
  enabled    = var.azure
}


# VM in MAAS.io

module "maas" {
  source     = "./modules/maas"
  module     = var.module
  ports      = var.ports
  public_key = var.public_key
  enabled    = var.maas
}


