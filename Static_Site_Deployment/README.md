# 🚗 Garage Website - Automated Netlify Deployment with Terraform

A beautiful automotive-themed static website that automatically deploys to Netlify using Terraform and HCP Terraform Cloud for state management.

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Netlify](https://img.shields.io/badge/netlify-%23000000.svg?style=for-the-badge&logo=netlify&logoColor=#00C7B7)

## 🌟 What This Project Does

This project automatically deploys a responsive garage/automotive website to Netlify with:
- **Random site names** (e.g., `garage-caring-dane.netlify.app`)
- **Dynamic content** - Random garage tips and featured tools on each deployment
- **Professional design** - Bootstrap-based responsive layout
- **Infrastructure as Code** - Everything managed through Terraform
- **Team collaboration** - Remote state stored in HCP Terraform Cloud

## 🎯 Live Demo

**Current Site:** https://garage-caring-dane.netlify.app

## 📋 Prerequisites

Before you start, make sure you have:

### Required Accounts
- [Terraform Cloud Account](https://app.terraform.io) (free)
- [Netlify Account](https://app.netlify.com) (free)

### Required Software
- **Terraform 1.0+** - [Download here](https://developer.hashicorp.com/terraform/downloads)
- **Git** - For cloning the repository

### System Requirements
- Linux/macOS/Windows with WSL2
- Internet connection for API calls

## 🚀 Quick Start Guide

### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd Static_Site_Deployment
```

### Step 2: Get Your Netlify Token
1. Go to [Netlify](https://app.netlify.com)
2. Click your profile → **User settings**
3. Go to **Applications** → **Personal access tokens**
4. Click **New access token**
5. Give it a name like "Terraform Deployment"
6. **Copy the token** (starts with `nfp_`)

### Step 3: Set Up HCP Terraform Workspace
1. Go to [Terraform Cloud](https://app.terraform.io)
2. Create an organization (or use existing)
3. Create a workspace named `netlify-static-site`
4. In your workspace, go to **Variables** tab
5. Add an **Environment Variable**:
   - **Key:** `NETLIFY_TOKEN`
   - **Value:** Your Netlify token from Step 2
   - **Sensitive:** ✅ **Check this box**
   - Click **Save**

### Step 4: Update Terraform Configuration
Edit `versions.tf` and update the organization name:
```hcl
cloud {
  organization = "your-organization-name"  # Change this to your org
  workspaces {
    name = "netlify-static-site"
  }
}
```

### Step 5: Authenticate with Terraform Cloud
```bash
terraform login
```
This will open your browser to authenticate with Terraform Cloud.

### Step 6: Deploy Your Site
```bash
# Initialize Terraform
terraform init

# Deploy the site
terraform apply -auto-approve
```

That's it! 🎉 Your site will be live in about 30 seconds.

## 📊 Expected Output

After running `terraform apply`, you'll see:
```
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:
site_url = "https://garage-awesome-tiger.netlify.app"
```

## 🎨 What Gets Deployed

Your live site includes:
- **Homepage** with garage services and featured cars
- **Contact page** with business information
- **Responsive design** that works on all devices
- **Dynamic content** that changes with each deployment:
  - Random garage maintenance tip
  - 3 randomly selected featured tools
  - Deployment timestamp and metadata

## 🔧 Project Structure

```
Static_Site_Deployment/
├── README.md                    # This file
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Input variables and garage content
├── terraform.tfvars            # Variable values
├── versions.tf                  # Terraform and provider versions
├── outputs.tf                   # Output definitions
├── modules/
│   └── garage-netlify-site/     # Custom Netlify deployment module
│       ├── main.tf              # Deployment logic
│       ├── variables.tf         # Module variables
│       ├── outputs.tf           # Module outputs
│       └── versions.tf          # Module provider requirements
└── Site/
    └── garage/                  # Static website files
        ├── index.html           # Homepage
        ├── contact.html         # Contact page
        ├── style/               # CSS files
        ├── source/              # Bootstrap, jQuery, fonts
        └── image/               # Car photos and graphics
```

## 🛠️ Customization Options

### Change Site Name Prefix
Edit `terraform.tfvars`:
```hcl
site_name_prefix = "my-garage"  # Will create "my-garage-random-name"
```

### Modify Garage Tips and Tools
Edit the lists in `variables.tf`:
```hcl
variable "garage_tips" {
  default = [
    "Your custom garage tip here",
    "Another helpful maintenance tip",
    # Add more tips...
  ]
}

variable "garage_tools" {
  default = [
    "Your essential tool",
    "Another important tool",
    # Add more tools...
  ]
}
```

### Update Website Content
Modify files in `Site/garage/`:
- `index.html` - Homepage content
- `contact.html` - Contact information
- `style/mystyle.css` - Custom styling
- `image/` - Replace with your own images

## 🔄 Common Commands

```bash
# View current infrastructure
terraform plan

# Deploy changes
terraform apply -auto-approve

# Destroy everything (removes the website)
terraform destroy -auto-approve

# View current state
terraform show

# Get output values
terraform output
```

## 🐛 Troubleshooting

### "Error: Required token could not be found"
**Solution:** Run `terraform login` to authenticate with Terraform Cloud.

### "Error: NETLIFY_TOKEN environment variable is required"
**Solution:** Make sure you added `NETLIFY_TOKEN` as a **sensitive environment variable** in your HCP Terraform workspace (not as a Terraform variable).

### Site shows 404 error
**Solution:** Wait 1-2 minutes for Netlify to process the deployment, then refresh.

### "Permission denied" errors
**Solution:** Make sure you're using the correct Netlify token with proper permissions.

### Changes not appearing
**Solution:** 
1. Make sure you saved your changes
2. Run `terraform apply` again
3. Check that files in `Site/garage/` were modified

## 🏗️ How It Works

1. **Random Generation:** Creates unique site names and selects random content
2. **Archive Creation:** Packages your website files into a ZIP archive
3. **Netlify API:** Uses Netlify's REST API to create sites and deploy content
4. **State Management:** Stores infrastructure state in HCP Terraform Cloud
5. **Output:** Returns the live website URL

## 🤝 Contributing

Feel free to:
- Add new garage tips and tools
- Improve the website design
- Enhance the Terraform modules
- Submit bug reports and feature requests

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🎯 Next Steps

After your site is running:
1. **Customize the content** with your own garage business information
2. **Add your own images** to make it unique
3. **Set up a custom domain** by adding the `custom_domain` variable
4. **Share your site** and show off your Infrastructure as Code skills!

---

**Happy deploying! 🚗💨**

*Built with ❤️ using Terraform and Netlify*