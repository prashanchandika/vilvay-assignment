terraform {
  required_providers {
    aws = "= 3.32.0"
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20210721.2-x86_64-gp2"]
  }

  filter {
       name   = "virtualization-type"
       values = ["hvm"]

 }


  owners = ["137112412989"] # Canonical
}

data "aws_iam_policy" "SSMAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "vilvay-web" {
  name        = "vilvay_web_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc

  tags = {
    Name = "Vilvay-Web-TF"
  }
}

resource "aws_security_group_rule" "egress" {
  type      = "egress"
  protocol  = "-1"
  to_port   = 0
  from_port = 0

  description       = "Allow all traffic out to any destination"
  security_group_id = aws_security_group.vilvay-web.id
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 81
  to_port           = 89
  security_group_id = aws_security_group.vilvay-web.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allowssh" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  security_group_id = aws_security_group.vilvay-web.id
  cidr_blocks       = var.vpc_ip_block
}


resource "aws_iam_role" "webserver_role" {
  name = "vilvay_web_serer_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "vilvay-web-server-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm-policy-attach" {
  role       = "${aws_iam_role.webserver_role.name}"
  policy_arn = "${data.aws_iam_policy.SSMAccess.arn}"
}


resource "aws_iam_instance_profile" "webserver_profile" {
  name = "vilvay_web_profile"
  role = "${aws_iam_role.webserver_role.name}"
}

# WEB SERVER############
resource "aws_instance" "web-server" {
  ami           = data.aws_ami.amazonlinux.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "vilvay-manual"
  subnet_id = var.ec2_subnet
  user_data = "${file("userdata.sh")}"
  vpc_security_group_ids = [aws_security_group.vilvay-web.id]
  iam_instance_profile = "${aws_iam_instance_profile.webserver_profile.name}"

  tags = {
    Name = "Vilvay-Web-TF"
  }
}


# ALB

resource "aws_security_group" "webalb_sg" {
  name        = "web_alb-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc

  tags = {
    Name = "Vilvay-WebALB-TF"
  }
}


resource "aws_lb" "webalb" {
  name               = "web-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webalb_sg.id]
  subnets            = var.alb_subnets

  enable_deletion_protection = false

  tags = {
    Environment = "env"
  }
}


resource "aws_security_group_rule" "albingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 89
  security_group_id = aws_security_group.webalb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "albegress" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 89
  security_group_id = aws_security_group.webalb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-lb-tg-tf"
  port     = 81
  protocol = "HTTP"
  vpc_id   = var.vpc
}

resource "aws_lb_target_group_attachment" "webserver_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web-server.id
  port             = 81
}

resource "aws_lb_listener" "webserer_alb_listener" {
  load_balancer_arn = aws_lb.webalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}



# ALB conmponents for DOCKER webserver
 
resource "aws_lb_target_group" "docker_web_tg" {
  name     = "docker-web-lb-tg-tf"
  port     = 82
  protocol = "HTTP"
  vpc_id   = var.vpc
}

resource "aws_lb_target_group_attachment" "docker_webserver_tg_attachment" {
  target_group_arn = aws_lb_target_group.docker_web_tg.arn
  target_id        = aws_instance.web-server.id
  port             = 82
}

resource "aws_lb_listener" "docker_webserer_alb_listener" {
  load_balancer_arn = aws_lb.webalb.arn
  port              = "82"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.docker_web_tg.arn
  }
}


