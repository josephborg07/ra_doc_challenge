provider "aws" {
  region = "us-east-1"
  access_key = "AKIAQWBDCKAHAXX5DZS4"
  secret_key = "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"
}

terraform {
  backend "s3" {
    bucket = "doc-tf"
    key    = "doc_share_state"
    region = "us-east-1"
  }
}