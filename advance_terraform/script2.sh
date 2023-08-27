#!/bin/bash

yum update -y
yum install httpd -y
echo "Hello Server 2" > /var/wwww/index.html
service start httpd
