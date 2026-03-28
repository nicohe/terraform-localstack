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

    # Estas opciones se configuran en tiempo de ejecución:
    # -backend-config="endpoint=http://localhost:4566"
    # -backend-config="access_key=test"
    # -backend-config="secret_key=test"
    
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

provider "docker" {}

# Provider local para archivos
provider "local" {}
