# Declare AWS access/secret key and region for AWS provider 
provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = var.region
}