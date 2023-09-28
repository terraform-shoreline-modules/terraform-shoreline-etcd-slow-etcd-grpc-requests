terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "slow_etcd_grpc_requests" {
  source    = "./modules/slow_etcd_grpc_requests"

  providers = {
    shoreline = shoreline
  }
}