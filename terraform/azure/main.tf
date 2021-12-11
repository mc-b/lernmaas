#######
#
#   Azure Cloud 


# VM in Azure

module "azure" {
  source     = "./modules/azure"
  module     = var.module
  ports      = var.ports
  public_key = var.public_key
  enabled    = var.azure
}

