terraform {
  required_version = "~> 1.5.7"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = ">=4.9.0" #Updated due to bug in provider on 3.6.9, Error: Provider produced inconsistent final plan
    }
    template = {
      source = "hashicorp/template"
      #version = "2.2.0"
    }
    local = {
      source = "hashicorp/local"
      #version = "2.1.0"
    }
    tls = {
      source = "hashicorp/tls"
      #version = "3.1.0"
    }
    random = {
      source = "hashicorp/random"
      #version = "3.1.0"
    }
  }
  backend "s3" {
    bucket = "qcloud-tf"
    key    = "medusa/terraform.tfstate"
    region = "us-east-2"
  }
}
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform = "true"
    }
  }

  # shared_credentials_file = "~/.aws/credentials"
  # profile                 = "development"
}
# Local variables used to reduce repetition
locals {
  node_username = "ubuntu"
}
