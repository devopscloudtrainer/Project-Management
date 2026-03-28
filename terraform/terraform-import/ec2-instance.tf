resource "aws_instance" "web_instance" {
  ami = "ami-03793655b06c6e29a"
  instance_type = "t3.micro"
  key_name = "mum-ap-pem-keys"
  vpc_security_group_ids = ["sg-0a54a00d4e02551c2"]
  tags = {
    Name = "webserver-instance"
  }
}
