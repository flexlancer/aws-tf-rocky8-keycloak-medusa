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
