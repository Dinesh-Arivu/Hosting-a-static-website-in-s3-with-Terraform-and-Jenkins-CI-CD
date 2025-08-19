terraform {
  backend "s3" {
    bucket         = "staticwebsitehostings3withjenkinsandterraform"
    key            = "my-terraform-environment/main"
    region         = "us-east-1"
    dynamodb_table = "staticwebsitehostings3table"
  }
}
