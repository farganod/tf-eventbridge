# Demo on how to use Terraform to setup EventBridge Cron Jon to Trigger Lambda

This code base provides a quick demo on leveraging Terraform as infrastructure as code (IaC) to deploy, manage, and integrate EventBridge rules with Lambda functions

If you are new to Terraform please see my [Terraform demo](https://github.com/farganod/tf_demo) repo on getting started 

# Usage

## Pre-requisites

Prior to using this repo you will need awscli and terraform installed on the system running the code. Links to instructions below:

* [AWSCLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
* [Terraform Download](https://www.terraform.io/downloads.html)
* [Terraform Install Guide](https://learn.hashicorp.com/terraform/getting-started/install)

## Running the Code

This code base is currently setup to store the `lock` and `state` remotely in DynamoDB and S3 respectively. Either update or remove the `config.tf` file to execute this code in your environment
