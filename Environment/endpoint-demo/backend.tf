terraform {
  backend "s3" {
    bucket = "terraform-backend-bucket-vishal"
    key    = "Compute/VPC-endpoints/EC2/test/terraform.tfstate"
    region = "ap-south-1"
  }
}