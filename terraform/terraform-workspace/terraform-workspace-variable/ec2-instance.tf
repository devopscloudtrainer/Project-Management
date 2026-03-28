resource "aws_instance" "web_instance" {
  ami = "ami-0ffef61f6dc37ae89"
  instance_type = "t3.micro"
  key_name = "mum-ap-pem-keys"
  vpc_security_group_ids = ["${aws_security_group.webserver-instance-sg.id}"]
  tags = {
    Name = "WebServer-${terraform.workspace}"
  }
}
