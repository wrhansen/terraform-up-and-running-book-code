# ASG

This is a test of the "asg" module that is defined under "../../modules/asg".

This module deploys a cluster of web server using EC2 and AutoScaling in an
AWS account.

## Pre-reqs

* You must have terraform installed
* You must have an AWS account

## Quick Start

Configure your AWS access keys as environment variables:

```
export AWS_ACCESS_KEY_ID=(your access key id here)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

Deploy the code:

```
terraform init
terraform apply
```

Clean up when you're done:

```
terraform destroy
```
