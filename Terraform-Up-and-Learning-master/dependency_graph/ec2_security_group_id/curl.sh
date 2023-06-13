#!/bin/bash

echo "1st args $1"
response=''

response=$(curl http://$1:8080)

cat<<-EOF

      AWS EC2, httpd response : $response

EOF