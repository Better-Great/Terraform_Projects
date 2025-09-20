# Create a temporary directory for site deployment
resource "local_file" "site_info" {
  content = jsonencode({
    name = var.site_name
    deploy_message = "Deploy ${var.deployment_timestamp} (${substr(var.content_hash, 0, 8)})"
  })
  filename = "/tmp/garage-site-info.json"
}

# Use Netlify CLI to create and deploy the site
resource "null_resource" "netlify_deployment" {
  # Trigger redeployment when content changes
  triggers = {
    content_hash = var.content_hash
    site_name = var.site_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      
      if [ -z "$NETLIFY_TOKEN" ]; then
        echo "Error: NETLIFY_TOKEN environment variable is required"
        exit 1
      fi
      
      echo "Deploying ${var.site_name} from ${var.site_zip_path}"
      
      # Check if site exists
      SITE_ID=$(curl -s -H "Authorization: Bearer $NETLIFY_TOKEN" \
          "https://api.netlify.com/api/v1/sites" | \
          jq -r '.[] | select(.name=="${var.site_name}") | .id' 2>/dev/null || echo "")
      
      # Create site if it doesn't exist
      if [ -z "$SITE_ID" ]; then
        echo "Creating new site: ${var.site_name}"
        SITE_DATA=$(curl -s -X POST \
            -H "Authorization: Bearer $NETLIFY_TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"name":"${var.site_name}"}' \
            "https://api.netlify.com/api/v1/sites")
        SITE_ID=$(echo "$SITE_DATA" | jq -r '.id')
        echo "Created site with ID: $SITE_ID"
      fi
      
      # Deploy the site
      echo "Deploying to site ID: $SITE_ID"
      DEPLOY_RESPONSE=$(curl -s -X POST \
          -H "Authorization: Bearer $NETLIFY_TOKEN" \
          -H "Content-Type: application/zip" \
          --data-binary "@${var.site_zip_path}" \
          "https://api.netlify.com/api/v1/sites/$SITE_ID/deploys")
      
      DEPLOY_URL=$(echo "$DEPLOY_RESPONSE" | jq -r '.ssl_url // .url')
      echo "NETLIFY_URL=$DEPLOY_URL" > /tmp/netlify_output.env
      echo "Site deployed successfully: $DEPLOY_URL"
    EOT
  }
  
  depends_on = [local_file.site_info]
}

# Read the site URL from the deployment output
data "local_file" "netlify_output" {
  filename = "/tmp/netlify_output.env"
  depends_on = [null_resource.netlify_deployment]
}
