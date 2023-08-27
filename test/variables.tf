variable "profile" {
  default = "demo"
}

variable "region" {
  default = "us-east-1"
}

variable "ami-id" {
  default = "ami-xxxxxx"
}

variable "amis" {
  type = "map"
  default = {
    us-east-1 = "ami-1xx"
    us-east-2 = "ami-2xx"
    us-east-3 = "ami-3xx"
  }
}