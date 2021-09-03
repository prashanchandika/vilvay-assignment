terraform {
  required_providers {
    aws = "= 3.32.0"
  }
   backend "s3" {
    bucket = "vilvay-terraform"
    key    = "tfstate"
    region = "us-east-1"
  }
}





provider "aws" {
  region = "us-east-1"
}


module "web-server"{
	source = "../../modules/ec2"
}
