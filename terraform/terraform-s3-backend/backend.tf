terraform {
  backend "s3" {
    bucket = "automation-infrastructure-insurance-department"
    key    = "automation/terraform.tfstate"
    region = "ap-south-1"
  }
}
