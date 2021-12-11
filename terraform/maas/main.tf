#######
#
#   MAAS Cloud 

# VM in MAAS.io

module "maas" {
  source     = "./modules/maas"
  module     = var.module
  ports      = var.ports
  public_key = var.public_key
  enabled    = var.maas
}


