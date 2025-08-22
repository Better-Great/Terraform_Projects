resource "netlify_site" "this" {
  name         = var.site_name
  custom_domain = var.custom_domain != "" ? var.custom_domain : null
}

resource "netlify_deploy" "this" {
  site_id    = netlify_site.this.id
  zip_path   = var.site_zip_path
  branch     = var.production_branch
  message    = "Deploy ${var.deployment_timestamp} (${substr(var.content_hash, 0, 8)})"
  # Optionally add environment variables or other config
}
