provider "aws" {
  profile = "demo"
  region = "us-east-1"
}

resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  cidr_block = "10.0.1.0/24"
  tag = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  cidr_block = "10.0.2.0/24"
  tag = {
    Name = "public-subnet2"
  }
}


resource "aws_internet_gateway" "vpc-igw" {
    vpc_id = "${aws_vpc.demo-vpc.id}"

}

resource "aws_network_nacl" "public-nacl" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  subnet_ids = ["${aws_subnet.public-subnet.id}"]
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "webserver-sg" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  name        = "WebDmz"
  description = "Security group for web server"

  ingress {
    description      = "Https from any where"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Http from Anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from Anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
  
}

resource "aws_security_group" "lb_sg" {
  vpc_id = "${aws_vpc.demo-vpc.id}"
  name        = "LoadbalancerSecurityGroup"
  description = "Security group for load balancer"
  ingress {
    description      = "Https from any where"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_web_traffic"
  }
}

resource "aws_instance" "web-server" {
  ami = "ami-xxxxxxxxx"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.webserver-sg.id}"]
  key_name = "DemoPairKey.pem"
  user_data = "${file(script.sh)}"
  subnet_id = "${aws_subnet.public-subnet.id}"
}
resource "aws_instance" "web-server2" {
  ami = "ami-xxxxxxxxx"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.webserver-sg.id}"]
  key_name = "DemoPairKey.pem"
  user_data = "${file(script2.sh)}"
  subnet_id = "${aws_subnet.public-subnet2.id}"
}

resource "aws_lb" "web-lb" {
  name               = "web-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb_sg.id}"]
  subnets            = ["${aws_subnet.public-subnet.id}", "${aws_subnet.public-subnet2.id}"]

  enable_deletion_protection = true
  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_listener" "web-lb-listener" {
  
}


