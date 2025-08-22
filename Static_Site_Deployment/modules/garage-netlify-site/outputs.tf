output "site_url" {
  description = "The live Netlify site URL."
  value       = netlify_site.this.ssl_url
}
