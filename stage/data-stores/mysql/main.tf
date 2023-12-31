terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "terraform-up-and-running-state-whansen"
    key    = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
provider "aws" {
  region = "us-east-1"
  alias  = "primary"
}

module "mysql_primary" {
  source = "../../../modules/data-stores/mysql"

  # Use the primary provider
  providers = {
    aws = aws.primary
  }

  db_name     = "stage_db"
  db_username = var.db_username
  db_password = var.db_password

  # Must be enabled to support replication
  backup_retention_period = 0
}


