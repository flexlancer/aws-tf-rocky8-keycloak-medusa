data "aws_ami" "ubuntu-20" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*amd*",
    ]
  }
  filter {
    name = "virtualization-type"
    values = [
      "hvm",
    ]
  }
}
resource "tls_private_key" "controller_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "private_key" {
  content         = tls_private_key.controller_private_key.private_key_pem
  filename        = "ubuntu20-key.pem"
  file_permission = 0400
}
resource "aws_key_pair" "controller_key" {
  key_name   = "ubuntu20-key"
  public_key = tls_private_key.controller_private_key.public_key_openssh
}

resource "aws_instance" "ubuntu-20-instance" {
  ami = data.aws_ami.ubuntu-20.id
  #ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.controller_key.key_name #need to use user > ubuntu
  vpc_security_group_ids = ["${aws_security_group.sg_allow_ssh.id}"]
  subnet_id              = aws_subnet.public-subnet-1.id
  iam_instance_profile   = "QCSOperatorRole"

  root_block_device {
    volume_size = 32
    tags = {
      Name     = "ub20-rootdir"
      customer = "pilot"
      use      = "rootdir"
    }
  }

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 32
    tags = {
      Name     = "ub20-workdir"
      customer = "pilot"
      use      = "workdir"
    }
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = tls_private_key.controller_private_key.private_key_pem
    timeout     = "1m"
  }

  user_data = file("ubuntu-install-medusa.sh")

  associate_public_ip_address = true

  tags = {
    Name = "ubuntu20-keycloak"
  }
}
output "ubuntu20_instance_public_dns" {
  description = "public_dns of EC2 instance"
  value       = aws_instance.ubuntu-20-instance.public_dns
}

resource "aws_security_group" "sg_allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH, http(s) ingress"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_static, var.vpc_cidr]
  }

  ingress {
    description = "Allow ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.public_static, var.vpc_cidr]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
