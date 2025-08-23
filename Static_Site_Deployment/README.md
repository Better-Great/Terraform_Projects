## Terraform Challenge – Netlify Site + HCP Terraform Remote State

### What this does
Deploys the `garage` static site to Netlify with Terraform. State is stored remotely in HCP Terraform for a team-ready workflow. Site naming uses a short random suffix so each run is unique.

### Prerequisites
- Terraform 1.0+
- Netlify account and Personal Access Token
- HCP Terraform (Terraform Cloud) org and workspace

### Remote state (HCP Terraform)
Configured in `versions.tf` using the `cloud` block:
- Organization: `zealot_projects`
- Workspace: `netlify-static-site`

Authenticate once locally:
```bash
terraform login
```

In the HCP Terraform workspace, add a sensitive environment variable:
- `NETLIFY_TOKEN` → your Netlify personal access token

### How credentials are handled
- The Netlify CLI uses `NETLIFY_TOKEN` from the environment for authentication. No tokens in code or `terraform.tfvars`.
- The deployment uses Netlify CLI via Terraform's local-exec provisioner.

### Run it
From `Static_Site_Deployment/`:
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Output:
- `site_url` → your live Netlify URL

### Customization
- `site_name_prefix` (default `garage`) in `terraform.tfvars`
- `site_directory` (default `Site/garage`) if you move site files
- Optional: `custom_domain`, `enable_branch_deploys`, `production_branch`

### Files of interest
- `main.tf` – archives `Site/garage`, injects simple deploy metadata, calls the Netlify module
- `modules/garage-netlify-site` – uses Netlify CLI to create the site and deploy the archive
- `variables.tf` – inputs including randomizable content used for metadata
- `outputs.tf` (module) – exposes `site_url`

### Prerequisites for deployment
- Node.js and npm (for Netlify CLI installation)
- jq (for JSON parsing in the deployment script)
- unzip utility

### .gitignore
Add a repo-level `.gitignore` with Terraform and local files excluded (example shown below in this README’s tips).

### Tips for the challenge deliverables
- Include the output `site_url` in your README
- Add a screenshot after a successful `terraform apply`
- Write a short blog post about how you wired Netlify + HCP Terraform and what makes your `garage` site unique. Tag the HUG Ibadan page.

### Troubleshooting
- If the provider fails auth, ensure `NETLIFY_TOKEN` is set in the HCP Terraform workspace environment variables and not in code.
- If apply shows no changes but you want a redeploy, any content change under `Site/garage` or the generated `garage-deploy.json` will trigger a new archive hash and a new deploy message.
