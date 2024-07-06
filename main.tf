terraform {
  required_version = "~> 1.5.7"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.0"
      version = "3.74.0" #else runtime error
    }
    template = {
      source = "hashicorp/template"
    }
    local = {
      source = "hashicorp/local"
    }
    tls = {
      source = "hashicorp/tls"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "s3" {
    bucket  = "qcloud-tf"
    key     = "aquinas/terraform.tfstate"
    region  = "us-east-2" #region of s3 bucket (NOT ec2 region)
    encrypt = true        #encrypted s3 file
    #shared_credentials_file = "/home/engineer/.aws/credentials"
    #profile                 = "default"
  }

  # FOR USE WITH TERRAFORM CLOUD
  #cloud {
  #  organization = "gt-gvillas"
  #  workspaces {
  #    name = "keycloak-prod"
  #  }
  #}

}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = var.environment
    }
  }
  #shared_credentials_file = ["/home/engineer/.aws/credentials"]
  #profile                  = "default"
}

resource "tls_private_key" "controller_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.controller_private_key.private_key_pem
  filename        = "${var.entity}-${var.environment}-key-tf.pem"
  file_permission = 0400
}

resource "aws_key_pair" "controller_key" {
  key_name   = "${var.entity}-${var.environment}-key-tf"
  public_key = tls_private_key.controller_private_key.public_key_openssh
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}
data "aws_ami" "rocky8" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name = "name"
    values = [
      "*Rocky-8*x86_64*",
    ]
  }
  /*  
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
*/
}
#module "awsbackup" {
#  source = "./modules/awsbackup"
#}

locals {
}

resource "aws_kms_key" "keycloakkms" {
  description             = "keycloak KMS vault key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "random_string" "rdspassword" {
  length      = 10
  special     = false
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  #override_special = "/"
}
