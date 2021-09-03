variable "vpc" {
  type = string
  default = "vpc-20d8a15d"
}
variable "vpc_ip_block" {
  type = list
  default = ["172.31.0.0/16"]
}

variable "ec2_subnet" {
  type = string
  default = "subnet-37a68d16"
}

variable "alb_subnets" {
  type = list
  default = ["subnet-37a68d16", "subnet-59c03c15"]
}
