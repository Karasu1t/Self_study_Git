# ---------------------------------------------
# Security Group
# ---------------------------------------------
# web security group
resource "aws_security_group" "web_sg" {
  name        = "${var.project}-${var.environment}-web-sg"
  description = "web front role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-web-sg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "web_in_http" {
  security_group_id = aws_security_group.web_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "web_out_http" {
  security_group_id = aws_security_group.web_sg.id
  protocol          = "-1"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"] # すべてのIPに対して許可
}

# LB security group
resource "aws_security_group" "lb_sg" {
  name        = "${var.project}-${var.environment}-lb-sg"
  description = "lb front role security group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}-${var.environment}-lb-sg"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_security_group_rule" "lb_in_http_80" {
  security_group_id = aws_security_group.lb_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_in_http_9000" {
  security_group_id = aws_security_group.lb_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 9000
  to_port           = 9000
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_out_http" {
  security_group_id = aws_security_group.lb_sg.id
  protocol          = "-1"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"] # すべてのIPに対して許可
}
