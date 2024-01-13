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

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

locals {
    aws = yamldecode(file("${path.root}/../../config.yaml")).aws
}