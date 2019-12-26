#!/bin/bash
#   
#   Installiert den Apache Web Server
#

sudo apt install -y apache2

# Home Verzeichnis unter http://<host>/user/ verfuegbar machen
mkdir -p /home/ubuntu/data/html
sudo ln -s /home/ubuntu/data/html /var/www/html/user

cat <<%EOF% >/home/ubuntu/data/html/index.html
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Testseite</title>
</head>
<body>
<h1>Testseite</h1>
</body>
</html>
%EOF%
