provider "aws" {
 profile = "${var.profile}"
 region = "${var.region}"
}

resource "aws_instance" "demo_instance" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"
    key_name = "DemoKeyPair.pem"
    vpc_security_group_ids = [ "sg-53regsxxxxxxxxxx" ]
    tags = {
        Name = "DemoInstance"
    }

    provisioner "file" {
      source = "script.sh"
      destination = "/tmp/script.sh"
    }

    provisioner "local-exec" {
      command = "echo ${aws_instance.demo_instance.private_ip} > private_ip.txt"
    }
    provisioner "remote-exec" {
      inline = [ 
        "chmod +x /tmp/script.sh",
        "sudo /tmp/script.sh"
      ]
    }

    connection {
      host = "${aws_instance.demo_instance.public_ip}"
      user="ec2-user"
      private_key = "${file("${var.private_key_path}")}"
    }
}