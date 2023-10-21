terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
   aws= {
     source  = "hashicorp/aws"
     version = "3.0.0"
   }

   docker= {
      source  = "hashicorp/docker"
      version = "2.16.0"
  }
  }
  }



provider "kubernetes" {
  # Configuration options
  config_path = "/root/.kube/config"

}

provider "aws" {
  profile = "default"
  region = "us-east-1"

}

provider "docker" {
  source = "kreuzwerker/docker"
      version = "2.16.0"

}

