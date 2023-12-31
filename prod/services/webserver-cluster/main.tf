terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-whansen"
    key    = "prod/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use webserver-cluster module
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  ami         = "ami-0aa2b7722dc1b5612"
  server_text = "New server text PROD"

  # Config variables
  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "terraform-up-and-running-state-whansen"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type      = "t2.micro"
  min_size           = 2
  max_size           = 10
  enable_autoscaling = true

  # define custom tags that are dynamically generated via for_each
  custom_tags = {
    Owner     = "team-foo"
    ManagedBy = "terraform"
  }
}

