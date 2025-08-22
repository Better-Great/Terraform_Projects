variable "site_name_prefix" {
  description = "Prefix for the Netlify site name"
  type        = string
  default     = "garage-site"
}

variable "site_directory" {
  description = "Path to the static site directory"
  type        = string
  default     = "Site/garage"
}

variable "custom_domain" {
  description = "Custom domain for the site (optional)"
  type        = string
  default     = ""
}

variable "enable_branch_deploys" {
  description = "Enable automatic branch deployments"
  type        = bool
  default     = true
}

variable "production_branch" {
  description = "Git branch to use for production deployments"
  type        = string
  default     = "main"
}

variable "garage_tips" {
  description = "List of garage tips to randomly display"
  type        = list(string)
  default = [
    "Always check your oil level monthly for optimal engine performance",
    "Keep your tire pressure at manufacturer specifications for better fuel economy",
    "A clean air filter can improve your car's performance by up to 10%",
    "Regular brake inspections can prevent costly repairs and ensure safety",
    "Wax your car every 3-4 months to protect the paint from UV damage",
    "Check your battery terminals for corrosion to prevent starting issues",
    "Replace windshield wipers every 6 months for clear visibility",
    "Keep a emergency kit in your garage: jumper cables, flashlight, and tools"
  ]
}

variable "garage_tools" {
  description = "Essential garage tools for car maintenance"
  type        = list(string)
  default = [
    "Socket wrench set",
    "Oil drain pan", 
    "Jack and jack stands",
    "Tire pressure gauge",
    "Multimeter",
    "Work light",
    "Safety glasses",
    "Mechanic's gloves"
  ]
}