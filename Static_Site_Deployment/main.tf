# Generate random identifier for unique site naming
resource "random_pet" "site_identifier" {
  length    = 2
  separator = "-"
}

# Select a random garage tip for this deployment
resource "random_shuffle" "garage_tip" {
  input        = var.garage_tips
  result_count = 1
}

# Select random garage tools to feature
resource "random_shuffle" "featured_tools" {
  input        = var.garage_tools
  result_count = 3
}

# Create deployment timestamp and derived values
locals {
  deployment_timestamp = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  site_name            = "${var.site_name_prefix}-${random_pet.site_identifier.id}"
}

# Write dynamic deployment metadata into the site directory so it is archived
resource "local_file" "deploy_metadata" {
  content = jsonencode({
    site_name        = local.site_name
    deployment_time  = local.deployment_timestamp
    garage_tip       = random_shuffle.garage_tip.result[0]
    featured_tools   = random_shuffle.featured_tools.result
  })
  filename = "${var.site_directory}/garage-deploy.json"
}

# Create archive of static site files
data "archive_file" "garage_site" {
  type        = "zip"
  source_dir  = var.site_directory
  output_path = "${path.module}/garage-site.zip"
  depends_on  = [local_file.deploy_metadata]
}

# Deploy the garage site using the custom module
module "garage_netlify_site" {
  source = "./modules/garage-netlify-site"

  # Site configuration
  site_name             = local.site_name
  site_zip_path         = data.archive_file.garage_site.output_path
  custom_domain         = var.custom_domain
  enable_branch_deploys = var.enable_branch_deploys
  production_branch     = var.production_branch

  # Dynamic content
  garage_tip           = random_shuffle.garage_tip.result[0]
  featured_tools       = random_shuffle.featured_tools.result
  deployment_timestamp = local.deployment_timestamp

  # Trigger redeployment when content changes
  content_hash = data.archive_file.garage_site.output_base64sha256
}

output "site_url" {
  description = "The live Netlify site URL"
  value       = module.garage_netlify_site.site_url
}
