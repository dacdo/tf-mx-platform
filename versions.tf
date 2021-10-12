terraform {
  required_version = "~> 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "dacdo-tfstate-bucket"
    key    = "vpc-s3/terraform.tfstate"
    region = "us-west-2"

    # For State Locking
    dynamodb_table = "tfstate-locking"
  }
}

provider "aws" {
  region = "us-west-2"
}
