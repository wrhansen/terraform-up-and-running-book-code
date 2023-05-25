terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-whansen"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use a module
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  # Config variables
  cluster_name           = "webservers-stage"
  db_remote_state_bucket = "terraform-up-and-running-state-whansen"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 2
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

