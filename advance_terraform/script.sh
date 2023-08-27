#!/bin/bash

yum update -y
yum install httpd -y
echo "Hello Server" > /var/wwww/index.html
service start httpd
