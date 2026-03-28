resource "aws_instance" "web_instance" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = "mum-ap-pem-keys"
  vpc_security_group_ids = ["${aws_security_group.webserver-instance-sg.id}"]
  tags = {
    Name = var.instance_name
    Env  = terraform.workspace
  }
}
