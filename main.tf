provider "aws" {
  region = "us-east-1"
}

module "connect" {
  source = "./modules/connect"

  instance_alias = "tfconnect"
  time_zone      = "America/Los_Angeles"
  queue_name     = "tf-queue"
}