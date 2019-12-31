# Docker und Kubernetes Umgebung

Docker und Kubernetes Umgebung mit einem Master und mehreren Workern, siehe Tab [Cluster-Info](#Cluster). Zusätzlich wurde der [TBZ Deployer](https://github.com/tbz-k8s/tbz_hf_va) gestartet.

Der TBZ-Deployer ermöglicht es für jeden Lehrenden, einer Klasse, mehrere Container zu starten. Dazu wird, pro Lernenden, ein Kubernetes Namespaces erzeugt und in diesem dann die Container (Pods) gestartet.

* [Link zum TBZ Deployer](:32700/)

## Weitere Dokumentation

Wie die Applikation zu benutzen ist, ist [hier](https://github.com/tbz-k8s/tbz_hf_va/blob/master/docs/howto/howto_tbz_deployer.md) beschrieben

Wie Ressourcen für die Applikation erstellt werden können ist [hier](https://github.com/tbz-k8s/tbz_hf_va/blob/master/docs/howto/HowToResource.md) beschrieben.

Die Voraussetzung sind [hier](https://github.com/tbz-k8s/tbz_hf_va/blob/master/docs/hauptstudie/technical_prerequisites.adoc) dokumentiert

Der TBZ-Deployer basiert auf einer Vertiefungsarbeit an der TBZ HF von [Niklaus Liechti](https://github.com/nliechti/tbz_hf_va).
