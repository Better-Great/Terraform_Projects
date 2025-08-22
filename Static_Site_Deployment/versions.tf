terraform {
  required_version = ">= 1.0"
  
  required_providers {
    netlify = {
      source  = "AegirHealth/netlify"
      version = "~> 0.15.0"
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
  }
  
  cloud {
    organization = "zealot_projects"
    workspaces {
      name = "netlify-static-site"
    }
  }
}