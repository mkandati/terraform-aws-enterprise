#!/bin/bash
set -e

dnf update -y
dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Enterprise Network</title>
</head>
<body>
    <h1>Enterprise Network Terraform Demo</h1>
    <h2>Application Load Balancer is Working!</h2>
    <p>This web server was configured automatically using Terraform user_data.</p>
    <p><strong>Hostname:</strong> $(hostname)</p>
</body>
</html>
EOF