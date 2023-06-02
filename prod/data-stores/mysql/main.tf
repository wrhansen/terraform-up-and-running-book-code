terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "terraform-up-and-running-state-whansen"
    key    = "prod/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
provider "aws" {
  region = "us-east-1"
  alias  = "primary"
}

provider "aws" {
  region = "us-west-1"
  alias  = "replica"
}

module "mysql_primary" {
  source = "../../../modules/data-stores/mysql"

  # Use the primary provider
  providers = {
    aws = aws.primary
  }

  db_name     = "prod_db"
  db_username = var.db_username
  db_password = var.db_password

  # Must be enabled to support replication
  backup_retention_period = 1
}

# Adding a second module to create a replica
module "mysql_replica" {
  source = "../../../modules/data-stores/mysql"

  # Use the replica provider
  providers = {
    aws = aws.replica
  }

  # Make this a replica of the primary
  replicate_source_db = module.mysql_primary.arn
}


