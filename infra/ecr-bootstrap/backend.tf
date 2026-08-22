terraform {
  backend "s3" {
    bucket = "memos-bucket-s3"
    key    = "memos/ecr/terraform.tfstate"
    region = "eu-west-2"

    encrypt      = true
    use_lockfile = true
  }
}
