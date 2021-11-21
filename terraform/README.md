## Terraform

[![](https://embed-fastly.wistia.com/deliveries/41c56d0e44141eb3654ae77f4ca5fb41.jpg)](https://learn.hashicorp.com/tutorials/terraform/infrastructure-as-code?in=terraform%2Faws-get-started&amp;wvideo=mo76ckwvz4)

Quelle: hashicorp
- - -

Terraform ist ein Open-Source- Infrastruktur als Code- Software-Tool, das von HashiCorp entwickelt wurde . Benutzer definieren und stellen die Rechenzentrumsinfrastruktur mithilfe einer deklarativen Konfigurationssprache namens HashiCorp Configuration Language (HCL) oder optional JSON bereit.

So stellen Sie die Infrastruktur mit Terraform bereit:

* **Scope**  - Identifizieren Sie die Infrastruktur für Ihr Projekt.
* **Author**  – Schreiben Sie die Konfiguration für Ihre Infrastruktur.
* **Initialize** `terraform init` – Installieren Sie die Plugins, die Terraform zum Verwalten der Infrastruktur benötigt.
* **Plan** `terraform plan` – Zeigen Sie eine Vorschau der Änderungen an, die Terraform an Ihre Konfiguration anpasst.
* **Apply** `terraform apply` – Nehmen Sie die geplanten Änderungen vor.
* **Destroy** `terraform destroy` – Löschen Sie die Infrastruktur, wenn Sie sie nicht mehr benötigen. 

**Tipp**: jede Cloud Plattform erlaubt die eben durchgeführte Aktion, z.B. das erstellen einer VM, als Template zu speichern. In diesem Template finden Sie die Werte welche nachher in die Terraform Konfiguration übertragen werden können, z.B. der Name einer VM-Vorlage.

Für die nachfolgenden Beispiele sind die CLI für Azure, AWS und das Terraform CLI zu installieren.

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
* [AWS CLI](https://aws.amazon.com/de/cli/)
* [Terraform Installation](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

Um eine VM in einer der Cloud Umgebungen (AWS, Azure, MAAS) zu erstellen, genügt es dieses Repository zu clonen, Terraform zu initialiseren und sich dem dem jeweilige CLI in der Cloud einzuloggen.

    git clone https://github.com/mc-b/lernmaas
    cd lernmaas/terraform
    terraform init
    
**Optional**: Anmelden in der Azure Cloud

    az login
    
**Optional**: Anmelden in der AWS Cloud

    aws configure
    AWS Access Key ID [****************....]:
    AWS Secret Access Key [****************....]:
    Default region name [us-west-2]: us-east-1
    Default output format [None]:    
    
VM für ein definiertes Modul siehe [config.yaml](../config.yaml), anlegen. `aws` = AWS, `azure` = Azure, `maas` = MAAS.io.
   
    terraform apply -auto-approve <cloud>=true -var module=<modul>
    
z.B. in der Azure Cloud, die Umgebung für das Modul M122 anlegen:     

    terraform apply -auto-approve -var azure=true -var module=m122-11

Wird die VM nicht mehr benötigt, kann sie wieder gelöscht werden:

    terraform destroy -auto-approve -var azure=true -var module=m122-11
