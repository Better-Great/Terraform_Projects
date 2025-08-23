output "site_url" {
  description = "The live Netlify site URL."
  value       = trimspace(split("=", data.local_file.netlify_output.content)[1])
}
