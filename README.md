# Online Marketplace Terraform Project

![Terraform CI](https://github.com/klode88/online-marketplace-terraform/actions/workflows/terraform-ci.yml/badge.svg)

## Overview
This project builds a production-style AWS infrastructure using Terraform...
 Production-style AWS infrastructure with Terraform + CI pipeline (GitHub Actions)
## CI Pipeline

- Runs Terraform validation and formatting checks
- Uses a custom Docker-based GitHub Action
- Executes Terraform plan using AWS credentials
- Triggered automatically on push to main branch##

- 🖥️ How I Built This (CLI Steps)

This section shows the main CLI steps I used so I can revisit the process and others can follow along.



1. Create .gitignore
```bash
ni .gitignore
notepad .gitignore
.terraform/
terraform.tfstate
terraform.tfstate.backup
*.tfplan

2. Initialize Git
git init

3. Stage and commit files
git add .
git status
git commit -m "Initial commit - Terraform project"

4. Connect to GitHub repository
git remote add origin https://github.com/klode88/online-marketplace-terraform.git
git branch -M main
git push -u origin main

5. Create GitHub Actions workflow structure
mkdir .github
mkdir .github/workflows
ni .github/workflows/terraform-ci.yml

6. Create custom GitHub Action (Docker-based)
mkdir .github/actions
mkdir .github/actions/terraform-check

ni .github/actions/terraform-check/action.yml
ni .github/actions/terraform-check/Dockerfile
ni .github/actions/terraform-check/entrypoint.sh

7. Push pipeline updates
git add .
git commit -m "Add Terraform CI pipeline and custom action"
git push

📌 Notes
Terraform state files are excluded using .gitignore
AWS credentials are stored securely using GitHub Secrets
The pipeline runs automatically on push to main
- 
