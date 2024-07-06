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
