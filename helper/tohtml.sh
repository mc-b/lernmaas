#!/bin/bash
#
#   Erzeugt eine HTML Seite mit allen Resource Pools und deren VMs
#

POOLS=$(maas $PROFILE machines read | jq -r '.[] | .pool.name ' | sort | uniq | grep -v default | grep -v intern | grep -v system)

# Header
cat <<%EOF%
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>$(hostname) MAAS Server</title>
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
        <h1 class="center">$(hostname) MAAS Server</h1>
        <form class="navbar-form navbar-left" method="POST" action="">
            <div class="form-group">
                <!-- Tabs -->
                <ul class="nav nav-tabs">
%EOF%

# Tabs Ueberschriften
for pool in ${POOLS}
do
    echo "<li><a data-toggle="tab" href="#${pool}">${pool}</a></li>" 
done   


cat <<%EOF% 
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
%EOF%
  
# Tabs Inhalte  
for pool in ${POOLS}
do  

    echo "<div id=\"${pool}\" class=\"tab-pane fade\"><br/><table border=1><tr><th>Hostname</th><th>IP Intern</th></tr>" 
    maas $PROFILE machines read | jq -r ".[] | select (.pool.name==\"${pool}\") | [.hostname, .ip_addresses] | flatten | @tsv " | sort | \
    awk '{ printf("<tr><td>%s</td><td><a href=\"http://%s\" target=\"_blank\">%s</a></td></tr>\n", $1, $2, $2 ) }' 
    echo "</table></div>" 

done

cat <<%EOF% 
                </div>                    

                <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
                <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js" type="text/javascript"></script>
                <!-- Latest compiled and minified JavaScript -->
                <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"
                    integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"
                    type="text/javascript"></script>
                 <script>
                // strip / bei Wechsel Port
                document.addEventListener('click', function(event) {
                  var target = event.target;
                  if (target.tagName.toLowerCase() == 'a')
                  {
                      var port = target.getAttribute('href').match(/^:(\d+)(.*)/);
                      if (port)
                      {
                         target.href = port[2];
                         target.port = port[1];
                      }
                  }
                }, false);
                </script>
            </div>
        </form>
    </div>
</body>
</html>
%EOF%
                