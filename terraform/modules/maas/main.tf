terraform {
  required_providers {
    maas = {
      source = "suchpuppet/maas"
      version = "3.1.3"
    }
  }
}

provider "maas" {
    # Configuration options
    api_version = "2.0"
    api_key = "4vqP2YgYppyWMhye9t:WBgJkHwMWV6M2ZNaeR:mWhEhyZNn6vM225H8ch7rMtjbWAT2gLU"
    api_url = "http://10.8.38.8:5240/MAAS"
}

resource "maas_instance" "vm" {
    count           = var.enabled ? 1 : 0
    deploy_hostname = var.module
    user_data       = data.template_file.lernmaas.rendered
    release_erase   = false
}


