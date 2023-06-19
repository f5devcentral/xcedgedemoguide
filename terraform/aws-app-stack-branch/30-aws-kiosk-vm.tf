resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.environment}-kiosk-key"  
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.key_pair.key_name}.pem"
  content  = tls_private_key.key_pair.private_key_pem
}

data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}

resource "aws_security_group" "kiosk_sg" {
  name        = "${var.environment}-kiosk-sg"
  description = "Allow RDP connections"
  vpc_id      = element(aws_vpc.vpc.*.id, 0)

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-kiosk-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "kiosk" {
  ami = data.aws_ami.windows.id
  instance_type = "t3.large"
  subnet_id = element(aws_subnet.subnet_a.*.id, 0)
  vpc_security_group_ids = [aws_security_group.kiosk_sg.id]
  source_dest_check = false
  key_name = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  get_password_data = true
  
  root_block_device {
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }
  
  tags = {
    Name        = "${var.environment}-kiosk"
    Environment = var.environment
  }
}

output "kiosk_address" {
  description = "Kiosk IP Address"
  value= aws_instance.kiosk.public_ip 
}

output "kiosk_user" {
  description = "Kiosk Username"
  value = "administrator"
}

output "kiosk_password" {
  description = "Kiosk Password"
  sensitive = true
  value=rsadecrypt(aws_instance.kiosk.password_data, tls_private_key.key_pair.private_key_pem) 
}