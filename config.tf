terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket = "fargano-statefiles"
    key    = "eventbridge-lambda-demo/remote-state-demo.tfstate"
    encrypt        = "true"
    dynamodb_table = "fargano-tflock"
  }
}

provider "aws"{
    region = "us-east-1"
}