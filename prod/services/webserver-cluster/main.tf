terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-whansen"
    key    = "prod/services/webserver-cluster/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use webserver-cluster module
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  # Config variables
  cluster_name           = "webservers-prod"
  db_remote_state_bucket = "terraform-up-and-running-state-whansen"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size      = 2
  max_size      = 10
}

# Scheduled Action for auto scaling group to ramp up during business hours and
# pull back during off hours

resource "aws_autoscaling_schedule" "scale_out_during_busines_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}
