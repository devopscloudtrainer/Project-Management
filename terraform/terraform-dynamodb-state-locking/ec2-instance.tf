resource "aws_instance" "web" {
  ami                    = "ami-0ffef61f6dc37ae89"
  instance_type          = "t3.medium"
  key_name               = "mum-ap-pem-keys"
  vpc_security_group_ids = ["${aws_security_group.web-sg.id}"]
  tags = {
    Name = "webserver-server"
  }
}
