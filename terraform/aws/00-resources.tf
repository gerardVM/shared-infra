locals {
    aws = yamldecode(file("${path.root}/../../${var.config_file}")).aws
}

variable "config_file" {
  type = string
  default = "config.yaml"
}

terraform {
  required_version = "~> 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.16.0"
    }
  }
}

provider "aws" {
  region = local.aws.region
}

provider "aws" {
  alias  = "identity_center"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}