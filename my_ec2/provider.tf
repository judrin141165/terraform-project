provider "aws" {
  profile = "default"
  region  = var.region-master
  alias = "east-1"

}

provider "aws" {
 profile = "default"
 region = var.region-worker
 alias = "west-2"
}

