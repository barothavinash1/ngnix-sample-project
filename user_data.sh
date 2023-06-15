#!/bin/bash
apt-get update
apt-get install -y nginx
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
echo "<!DOCTYPE html>
<html>
<head>
  <title>My Nginx Page</title>
</head>
<body>
  <h1>Nginx-Lab!</h1>
  <p>Instance Private IP: $PRIVATE_IP</p>
</body>
</html>" > /var/www/html/index.html
service nginx start