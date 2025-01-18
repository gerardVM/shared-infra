locals {
    aws = yamldecode(file("${path.root}/../../${var.configuration}")).aws
}

variable "configuration" {
  type = string
  default = "config.yaml" # REMOVE ASAP
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
  alias  = "us-east-1"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}