locals {
  aws           = yamldecode(file("${path.root}/../../${var.config}")).aws
  account_0_aws = yamldecode(file("${path.root}/../../account_0.yaml")).aws
}

variable "config" {
  type    = string
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