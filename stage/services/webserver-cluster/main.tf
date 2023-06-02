terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-whansen"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
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

  # Tags to apply to all AWS resources by default
  default_tags {
    tags = {
      Owner     = "team-foo"
      ManagedBy = "Terraform"
    }
  }
}

# Use a module
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  ami         = "ami-0aa2b7722dc1b5612"
  server_text = "New server text STAGE"

  # Config variables
  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "terraform-up-and-running-state-whansen"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type      = "t2.micro"
  min_size           = 2
  max_size           = 2
  enable_autoscaling = false

  custom_tags = {
    Owner     = "team-foo"
    ManagedBy = "terraform"
  }
}

# Expose an extra port (just in staging environment)!
resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

