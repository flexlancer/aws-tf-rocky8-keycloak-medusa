variable "region" {
  default = "us-east-2"
}
variable "environment" {
  default = "Production"
}
variable "vpc_cidr" {
  description = "VPC cidr block"
}
variable "public_subnet_1_cidr" {
  description = "Public Subnet 1 cidr block"
}
variable "public_subnet_2_cidr" {
  description = "Public Subnet 2 cidr block"
}
variable "public_subnet_3_cidr" {
  description = "Public Subnet 3 cidr block"
}
variable "private_subnet_1_cidr" {
  description = "Private Subnet 1 cidr block"
}
variable "private_subnet_2_cidr" {
  description = "Private Subnet 2 cidr block"
}
variable "private_subnet_3_cidr" {
  description = "Private Subnet 3 cidr block"
}
variable "instance_type" {
  default = "t3.small"
}
variable "instance_ami" {
  default = "ami-05788af9005ef9a93"
}
variable "natgateway_eip" {
  description = "Update required when modifying ips"
}
variable "cluster" {
  default = "aristotle"
}
variable "public_static" {
  default = "0.0.0.0/0"
}