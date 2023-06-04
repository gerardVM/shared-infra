terraform {
  required_version = ">= 1.4.4"

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

locals {
    aws  = yamldecode(file("${path.root}/../../config.yaml")).aws
    sops = yamldecode(file("${path.root}/../../config.enc.yaml")).sops
}