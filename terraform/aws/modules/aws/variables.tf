
# Allgemeine Variablen

variable "image" {
  description = "Image Id"
  type        = string
  # Einziges Ubuntu welche mit AWS Academy funktioniert (amazon/cloud9ubuntu-2021-10 - ziemlich vermurkst)
  default     = "ami-001263f2e149e23d3"
  # Standard Ubuntu 20.04 LTS
  # default     = "ami-083654bd07b5da81d"
}

# Scripts

data "template_file" "lernmaas" {
  # Hack um verkorstes AWS Ubuntu Linux zuerst zu saeubern
  template = templatefile("${path.module}/lernmaas-hack.tpl", { module = var.module, public_key = var.public_key } )
  # Standard Cloud-init fuer alle Cloud Umgebungen identisch!
  # template = templatefile("${path.module}/../scripts/lernmaas.tpl", { module = var.module, public_key = var.public_key } )
}

# Public Variablen

variable "module" {
    type    = string
    default = ""
}

variable "public_key" {
    type    = string
    default = ""
}

variable "ports" {
    type    = list(number)
    default = [ 22, 80 ]
}

variable "enabled" {
    type    = bool
    default = false
}




