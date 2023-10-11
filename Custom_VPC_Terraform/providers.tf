provider "aws" {
  profile = "deault"
  region  = "us-east-2"
  alias   = "region-master"
}

provider "aws" {
profile = "default"
region = "us-east-1"
alias = "region-worker"

}