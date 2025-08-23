terraform {
  required_version = ">= 1.0"
  
  required_providers {
    netlify = {
      source  = "netlify/netlify"
      version = ">= 0.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
  }
  
  cloud {
    organization = "zealot_projects"
    workspaces {
      name = "netlify-static-site"
    }
  }
}