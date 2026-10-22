terraform {
  backend "s3" {
    bucket = "terraform-backend-bucket-vishal"
    key    = "Network/VPC-endpoints/test/terraform.tfstate"
    region = "ap-south-1"
  }
}