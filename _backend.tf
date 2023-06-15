terraform {
  backend "s3" {
    bucket = "nginx-terraform"
    key    = "nginx-terraform"
    region = "us-east-1"
  }
}
