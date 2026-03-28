terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  # Backend S3 con LocalStack
  backend "s3" {
    bucket = "terraform-state-roxs"
    key    = "terraform.tfstate"
    region = "us-east-1"

    # Configuración mediante variables de entorno:
    # export AWS_ACCESS_KEY_ID="test"
    # export AWS_SECRET_ACCESS_KEY="test"
    # export AWS_ENDPOINT_URL_S3="http://localhost:4566"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}

provider "docker" {}

# Provider local para archivos
provider "local" {}
