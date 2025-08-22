variable "site_name" {
  description = "Unique name for the Netlify site."
  type        = string
}

variable "site_zip_path" {
  description = "Path to the zipped static site files."
  type        = string
}

variable "custom_domain" {
  description = "Custom domain for the site (optional)."
  type        = string
  default     = ""
}

variable "enable_branch_deploys" {
  description = "Enable branch deploys on Netlify."
  type        = bool
  default     = false
}

variable "production_branch" {
  description = "Production branch name."
  type        = string
  default     = "main"
}

variable "garage_tip" {
  description = "Garage tip to display."
  type        = string
}

variable "featured_tools" {
  description = "List of featured garage tools."
  type        = list(string)
}

variable "deployment_timestamp" {
  description = "Timestamp of deployment."
  type        = string
}

variable "content_hash" {
  description = "Hash to trigger redeployment."
  type        = string
}
