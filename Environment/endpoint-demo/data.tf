#################################################
# NETWORK REMOTE STATE
#################################################

data "terraform_remote_state" "network" {

  backend = "s3"

  config = {

    bucket = "terraform-backend-bucket-vishal"
    key    = "Network/VPC-endpoints/test/terraform.tfstate"
    region = "ap-south-1"
  }
}