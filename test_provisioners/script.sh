#!/bin/bash

yum update -y
yum install httpd -y
echo "Hello world" > /var/www/html/index.html
service httpd restart
