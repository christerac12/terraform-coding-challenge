terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "resource "aws_s3_bucket" "my_lab_bucket" {
  bucket = "christer-terraform-challenge"
}

