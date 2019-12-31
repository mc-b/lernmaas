#!/bin/bash
#
#   Stellt ein einfaches Web UI zu Kubernetes zur Verfuegung
#

sudo apt install -y apache2 jq markdown
sudo a2enmod cgi
sudo systemctl restart apache2

sudo chmod +x /opt/lernmaas/cgi-bin/*
sudo cp /opt/lernmaas/cgi-bin/* /usr/lib/cgi-bin/

CLUSTER=$(kubectl --kubeconfig /home/vagrant/.kube/config config view -o=jsonpath='{ .clusters[0].cluster.server }' | sed -e 's/https:/http:/' -e "s/:6443//g")

cat <<%EOF% | sudo tee /var/www/html/index.html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>$(hostname) Web UI</title>
<link rel="shortcut icon" href="https://kubernetes.io/images/favicon.png">
<meta charset="utf-8" content="">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these 
        
    <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
    integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css"
    integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
</head>

<body>
    <div class="container">
        <h1 class="center">$(hostname) Web UI</h1>
        <form class="navbar-form navbar-left" method="POST" action="">
            <div class="form-group">
                <!-- Tabs -->
                <ul class="nav nav-tabs">
                    <li class="active"><a data-toggle="tab" href="#Intro">Intro</a></li>
                    <li><a data-toggle="tab" href="#Services">Services</a></li>
                    <li><a data-toggle="tab" href="#Pods">Pods</a></li>
                    <li><a data-toggle="tab" href="#Cluster">Cluster-Info</a></li>
                    <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                    <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                    <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                    <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                    <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                    <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                    <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                    <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
                </ul>

                <div class="tab-content">
                    <!--  Intro -->
                    <div id="Intro" class="tab-pane fade in active">
                        $(markdown $1)
                    </div>                
                    <!--  Services -->
                    <div id="Services" class="tab-pane fade">
                        <br/>
                         <iframe frameborder="0" scrolling="no" width="100%" height="3200px" onload="scroll(0,0);" src="${CLUSTER}/cgi-bin/services">
                         </iframe>
                    </div>
                    <!--  Pods -->
                    <div id="Pods" class="tab-pane fade">
                        <br/>
                         <iframe frameborder="0" scrolling="no" width="100%" height="3200px" onload="scroll(0,0);" src="${CLUSTER}/cgi-bin/pods">
                         </iframe>
                    </div>
                    <!--  Cluster Info -->
                    <div id="Cluster" class="tab-pane fade">
                        <br/>
                         <iframe frameborder="0" scrolling="no" width="100%" height="3200px" onload="scroll(0,0);" src="${CLUSTER}/cgi-bin/cluster">
                         </iframe>
                    </div>                    
                </div>                    

                <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js" type="text/javascript"></script>
                <!-- Latest compiled and minified JavaScript -->
                <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
                    integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"
                    type="text/javascript"></script>

            </div>
        </form>
    </div>
</body>
</html>
%EOF%

 
