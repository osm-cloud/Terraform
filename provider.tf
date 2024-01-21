terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }

    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }

    archive = {
      source = "hashicorp/archive"
      version = "2.4.0"
    }
  }
}

# # Configure the AWS Provider on Profile
# provider "aws" {
#   region = "<region>"
#   profile = "<profile name>"
# }

# # Configure the AWS Provider on Access Key
# provider "aws" {
#   region = "<region>"
#   access_key = "<access_key>"
#   secret_key = "<secret_key>"
# }

provider "tls" {
}

provider "local" {
}

provider "archive" {
}

data "aws_caller_identity" "caller" {
}
