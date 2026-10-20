terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"

  # 所有资源自动带上 Project=saa-lab 标签
  default_tags {
    tags = {
      Project = "saa-lab"
    }
  }
}
