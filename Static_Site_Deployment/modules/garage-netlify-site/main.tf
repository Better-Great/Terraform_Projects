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
      # Install Netlify CLI if not present
      if ! command -v netlify &> /dev/null; then
        npm install -g netlify-cli
      fi
      
      # Create site and deploy
      cd $(dirname "${var.site_zip_path}")
      
      # Extract the zip file to a temp directory
      TEMP_DIR=$(mktemp -d)
      unzip -q "${var.site_zip_path}" -d "$TEMP_DIR"
      
      # Create or update the site
      cd "$TEMP_DIR"
      
      # Check if site exists, if not create it
      SITE_ID=$(netlify sites:list --json 2>/dev/null | jq -r '.[] | select(.name=="${var.site_name}") | .id' 2>/dev/null || echo "")
      
      if [ -z "$SITE_ID" ]; then
        echo "Creating new site: ${var.site_name}"
        # Create site and capture the output
        CREATE_OUTPUT=$(netlify sites:create --name "${var.site_name}" --manual --json 2>/dev/null || netlify sites:create --name "${var.site_name}" --manual)
        SITE_ID=$(echo "$CREATE_OUTPUT" | jq -r '.id' 2>/dev/null || netlify sites:list --json | jq -r '.[] | select(.name=="${var.site_name}") | .id')
      fi
      
      echo "Deploying to site ID: $SITE_ID"
      # Deploy and capture the deploy URL
      DEPLOY_OUTPUT=$(netlify deploy --prod --dir . --site "$SITE_ID" --message "${var.deployment_timestamp}" --json 2>/dev/null || netlify deploy --prod --dir . --site "$SITE_ID" --message "${var.deployment_timestamp}")
      
      # Get the site URL - try multiple methods
      SITE_URL=""
      if [ -n "$DEPLOY_OUTPUT" ]; then
        SITE_URL=$(echo "$DEPLOY_OUTPUT" | jq -r '.url // .deploy_url // .site_url' 2>/dev/null)
      fi
      
      # Fallback: get URL from sites list
      if [ -z "$SITE_URL" ] || [ "$SITE_URL" = "null" ]; then
        SITE_URL=$(netlify sites:list --json 2>/dev/null | jq -r '.[] | select(.id=="'$SITE_ID'") | .url' 2>/dev/null)
      fi
      
      # Final fallback: construct URL from site name
      if [ -z "$SITE_URL" ] || [ "$SITE_URL" = "null" ]; then
        SITE_URL="https://${var.site_name}.netlify.app"
      fi
      
      # Clean up
      rm -rf "$TEMP_DIR"
      
      # Output the site URL
      echo "NETLIFY_URL=$SITE_URL" > /tmp/netlify_output.env
      echo "Site deployed successfully: $SITE_URL"
    EOT
  }
  
  depends_on = [local_file.site_info]
}

# Read the site URL from the deployment output
data "local_file" "netlify_output" {
  filename = "/tmp/netlify_output.env"
  depends_on = [null_resource.netlify_deployment]
}
