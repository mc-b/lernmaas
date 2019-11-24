Customising
----------- 

Die Installation der Maschinen kann angepasst werden. 

Dazu sind im Verzeichnis `/etc/maas/preseeds/` nach folgendem Namensschema Dateien zu erstellen:

    {prefix}_{osystem}_{node_arch}_{node_subarch}_{release}_{node_name}
    {prefix}_{osystem}_{node_arch}_{node_subarch}_{release}
    {prefix}_{osystem}_{node_arch}_{node_subarch}
    {prefix}_{osystem}_{node_arch}
    {prefix}_{osystem}
    {prefix}

**Beispiel Ubuntu**

Datei `/etc/maas/preseeds/curtin_userdata_ubuntu` erstellen und folgendes eintragen:

    #cloud-config
    debconf_selections:
     maas: |
      {{for line in str(curtin_preseed).splitlines()}}
      {{line}}
      {{endfor}}
    #
    late_commands:
      maas: [wget, '--no-proxy', {{node_disable_pxe_url|escape.json}}, '--post-data', {{node_disable_pxe_data|escape.json}}, '-O', '/dev/null']
      10_git: ["curtin", "in-target", "--", "sh", "-c", "apt-get -y install git curl wget"]
      20_git: ["curtin", "in-target", "--", "sh", "-c", "git clone https://github.com/mc-b/lernkube /home/ubuntu/lernkube && chown -R 1000:1000 /home/ubuntu/lernkube"]
      30_git: ["curtin", "in-target", "--", "sh", "-x", "/home/ubuntu/lernkube/scripts/docker.sh"]

Beim Deployen von Ubuntu Images wird zusätzlich das Projekt `lernkube` geclont und Docker installiert. 
Die `maas` Befehle sind notwendig, dass die VM richtig beendet wird und sauber rebooted.

### Links

* [Customising MAAS installs](https://ubuntu.com/blog/customising-maas-installs)
* [curtin](https://maas.io/docs/custom-node-setup-preseed) 
* [Customising MAAS](https://ubuntu.com/blog/customising-maas-installs)
* [Customising MAAS installs](http://mattjarvis.org.uk/post/customising-maas/)
* [Custom partitioning with Maas and Curtin](http://caribou.kamikamamak.com/2015/06/26/custom-partitioning-with-maas-and-curtin-2/)
