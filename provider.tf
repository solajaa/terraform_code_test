provider "aws" {
    region = var.region
}
terraform {
    #required_version = ">= 0.12"
    backend "s3" {
      bucket = "terrafom"
      key = "terrafom/state.tfstate"
      region = "us-east-1"
    }
    
}

provider "aws" {
  alias  = "acm_provider"
  region = "us-east-1"
}