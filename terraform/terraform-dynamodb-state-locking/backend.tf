terraform {
  backend "s3" {
    bucket         = "ecommerce-website-management-products"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
