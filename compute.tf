resource "aws_instance" "keycloak-master-instance" {
  ami = data.aws_ami.rocky8.id
  #ami           = var.instance_ami
  instance_type = var.keycloak_master_instance_type

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  key_name               = aws_key_pair.controller_key.key_name
  vpc_security_group_ids = ["${aws_security_group.sg_keycloak.id}"]
  subnet_id              = aws_subnet.public-subnet-1.id
  iam_instance_profile   = "QCSOperatorRole"

  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "rocky"
    host        = self.public_ip
    private_key = tls_private_key.controller_private_key.private_key_pem
  }

  user_data = file("test.sh")

  root_block_device {
    volume_size = 22
    encrypted   = true
    kms_key_id  = aws_kms_key.keycloakkms.arn

    tags = {
      Name = "${var.entity}-${var.environment}-master-root"
    }
  }

  ebs_block_device {
    device_name = "/dev/xvdf"
    volume_size = 8
    encrypted   = true
    kms_key_id  = aws_kms_key.keycloakkms.arn

    tags = {
      Name = "${var.entity}-${var.environment}-master-ebs"
    }
  }

  tags = {
    Name = "${var.entity}-${var.environment}-keycloak-master"
  }
}

output "keycloak_master_instance_public_dns" {
  value = aws_instance.keycloak-master-instance.public_dns
}
/*
resource "aws_instance" "keycloak-worker-instance" {
  #ami                    = "ami-05a36e1502605b4aa" #centos 7 us-east-2
  #ami                    = "ami-0b4e9a8bef23a039b" #Rocky 9 us-east-2  
  ami                    = "ami-0ce24f7d9f52a2d88" #Rocky 8
  #ami           = var.instance_ami
  instance_type = var.keycloak_worker_instance_type
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  key_name               = aws_key_pair.controller_key.key_name
  vpc_security_group_ids = ["${aws_security_group.sg_keycloak.id}"]
  subnet_id              = aws_subnet.public-subnet-1.id
  iam_instance_profile   = "QCSOperatorRole"

  associate_public_ip_address = true

  connection {
    type        = "ssh"
    #user        = "ec2-user"
    user        = "rocky"
    host        = self.public_ip
    private_key = tls_private_key.controller_private_key.private_key_pem

  }

  user_data = file("init_medusa_rocky8.sh")

  root_block_device {
    volume_size = 128
    encrypted   = true
    kms_key_id  = aws_kms_key.keycloakkms.arn

    tags = {
      Name    = "${var.entity}-${var.environment}-worker-root"
      qcs-use = var.entity
    }
  }

  ebs_block_device {
    device_name = "/dev/xvda2"
    #volume_size = 16
    encrypted   = true
    kms_key_id  = aws_kms_key.keycloakkms.arn

    tags = {
      Name    = "${var.entity}-${var.environment}-worker-ebs"
      qcs-use = var.entity
    }
  }

  tags = {
    Name = "${var.entity}-${var.environment}-keycloak-worker"
  }
}

output "keycloak_worker_instance_public_dns" {
  value = aws_instance.keycloak-worker-instance.public_dns
}
*/
resource "aws_security_group" "sg_keycloak" {
  name        = "sg_keycloak_${var.entity}-${var.environment}"
  description = "${var.entity}-${var.environment} - Allows SSH and web browsing"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "${var.entity}-${var.environment} - HTTP traffic from qcs fiber, qcs coax, private lan"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.static_fiber, var.static_coax, var.vpc_cidr]
  }

  ingress {
    description     = "${var.entity}-${var.environment} - HTTP traffic from lb - tf created - 8080"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_lb_keycloak.id]
  }

  ingress {
    description = "${var.entity}-${var.environment} - SSH from qcs fiber & qcs coax, private network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.static_fiber, var.static_coax, var.vpc_cidr]
  }

  ingress {
    description = "${var.entity}-${var.environment} - Allow ping  to master from private LAN"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
    #security_groups = [aws_security_group.sg_eval.id, aws_security_group.distributed_sg_eval.id]
  }

  ingress {
    description = "${var.entity}-${var.environment} - Allow keycloak ports"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [var.static_fiber, var.static_coax, var.vpc_cidr]
  }

  ingress {
    description     = "${var.entity}-${var.environment} - HTTP traffic from lb - tf created - 8443"
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_lb_keycloak.id]
  }

  ingress {
    description = "${var.entity}-${var.environment} - Allow postgres ports"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.static_fiber, var.static_coax, var.vpc_cidr]
  }

  egress {
    description = "${var.entity}-${var.environment} - egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_${var.entity}-${var.environment}"
  }
}

#Required for frontend.tf, but referenced in sg_keycloak
resource "aws_security_group" "sg_lb_keycloak" {
  name        = "${var.entity}-${var.environment}-qcs-loadbalancer-tf"
  description = "${var.entity}-${var.environment} - Allows http(s) web browsing from WHITELISTed IPs"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.static_coax, var.static_fiber]
    description = "${var.entity}-${var.environment} - HTTP from qcs static coax, fiber, ${var.entity} office"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.static_coax, var.static_fiber]
    description = "${var.entity}-${var.environment} - HTTPS from qcs static coax, fiber, ${var.entity} office"
  }

  egress {
    description = "${var.entity}-${var.environment} - egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_lb_${var.entity}-${var.environment}"
  }
}
