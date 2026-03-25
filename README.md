# FMCG Consumption Dashboard – CI/CD with Terraform & GitHub Actions

This repository contains a complete DevOps pipeline that generates a static HTML dashboard from Python data, provisions an S3 bucket with Terraform, and deploys the dashboard using GitHub Actions. The dashboard is hosted as a static website on AWS S3 and is updated automatically on every push.

## Table of Contents
- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Repository Structure](#repository-structure)
- [How It Works](#how-it-works)
- [Usage](#usage)
- [Output](#output)
- [Cleanup](#cleanup)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Project Overview

The pipeline:
1. **Generates** an HTML report from Python (simulating factory data).
2. **Provisions** an AWS S3 bucket configured for static website hosting using Terraform.
3. **Deploys** the HTML file to the bucket via GitHub Actions.
4. **Makes the file public** so it can be accessed via the bucket’s website endpoint.

This setup demonstrates how to automate infrastructure and deployment using Infrastructure as Code (IaC) and CI/CD practices.

## Architecture

```mermaid
graph LR
    A[Git Push] --> B[GitHub Actions]
    B --> C[Python: Generate index.html]
    B --> D[Terraform: Create S3 Bucket]
    D --> E[AWS S3 Bucket<br/>(Static Website)]
    C --> F[Upload to S3]
    F --> E
    E --> G[Public Dashboard URL]
```

## Prerequisites

- **AWS Account** with permissions to create S3 buckets and manage IAM.
- **GitHub Repository** (public or private).
- **AWS CLI** (optional, for local testing).
- **Terraform** (optional, for local runs).
- **Python 3.9+** (if running locally).

## Setup Instructions

### 1. Create an IAM User for GitHub Actions

1. In the AWS Console, go to **IAM → Users → Create user**.
   - Name: `github-action-user`
   - Enable **Programmatic access** (Access key ID + Secret access key).
2. Attach the **AdministratorAccess** policy (or a custom policy with permissions for S3 and Terraform state).
3. Copy the **Access Key ID** and **Secret Access Key**.

### 2. Add Secrets to GitHub

1. In your GitHub repository, go to **Settings → Secrets and variables → Actions**.
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### 3. Fork or Clone the Repository

```bash
git clone https://github.com/Senyene/fmcg-consumption-devops.git
cd fmcg-consumption-devops
```

### 4. Customize the Data (Optional)

Edit `generate_report.py` to modify the factory data (location, status, weight, efficiency). The HTML will be generated automatically.

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── terraform/
│   └── main.tf                 # Terraform configuration (S3 bucket, ACL, website)
├── generate_report.py          # Python script that creates index.html
└── README.md                   # This file
```

### Key Files

- **`deploy.yml`**: Workflow that triggers on `push`. It runs Python, Terraform, and uploads the file.
- **`main.tf`**: Terraform code that creates a unique S3 bucket, sets public access, configures static website, and outputs the bucket name and website URL.
- **`generate_report.py`**: Python script that injects data into an HTML template and saves it as `index.html`.

## How It Works

### GitHub Actions Workflow (`deploy.yml`)

1. **Checkout** the code.
2. **Set up Python** (3.9).
3. **Generate Dashboard** – runs `generate_report.py` to create `index.html`.
4. **Setup Terraform** – installs Terraform.
5. **Terraform Init & Apply** – initialises and applies the Terraform configuration in `./terraform`.
6. **Upload to S3** – extracts the bucket name from Terraform output and uploads `index.html` with `public-read` ACL.

### Terraform (`main.tf`)

- Creates a random ID to make the bucket name unique (`fmcg-consumption-dashboard-<random>`).
- Configures the bucket for public access (disables block public access).
- Sets **object ownership** to `BucketOwnerPreferred`.
- Applies a **public-read ACL** to the bucket.
- Configures **static website hosting** with `index.html` as the index document.
- Outputs the bucket name and website URL.

### Python Script (`generate_report.py`)

- Stores factory data as a dictionary.
- Renders an HTML template using an f-string.
- Writes the output to `index.html`.

## Usage

Every time you push to the repository, the workflow runs and updates the dashboard.

To manually trigger a deployment, go to the **Actions** tab in GitHub and re-run the latest workflow.

### Updating the Dashboard

1. Edit `generate_report.py` and modify the `factory_data` dictionary.
2. Commit and push the changes.
3. The pipeline will generate a new `index.html` and upload it.

## Output

After a successful run, the dashboard is accessible at the website URL. For example:

**Bucket name:** `fmcg-consumption-dashboard-9324cefe`  
**Website URL:** `http://fmcg-consumption-dashboard-9324cefe.s3-website-us-east-1.amazonaws.com/`

You can find the exact URL in the **Terraform Init and Apply** step logs (search for `website_url`).

## Cleanup

### Remove the Infrastructure

To delete the S3 bucket and all associated resources, run from the `terraform/` directory:

```bash
cd terraform
terraform destroy -auto-approve
```

### Delete Extra Buckets (Optional)

```bash
# List buckets
aws s3api list-buckets --query "Buckets[?starts_with(Name, 'fmcg-consumption-dashboard-')].[Name]" --output text

# Delete a specific bucket
aws s3 rb s3://<bucket-name> --force
```

## Troubleshooting

### 1. Terraform fails with `AccessDenied` on `PutBucketPolicy`
- **Cause**: Account-level S3 Block Public Access prevents bucket policies.
- **Solution**: The project uses ACLs instead of bucket policies, so this should not occur. Ensure "Block public policies" is handled appropriately.

### 2. The website shows `403 Forbidden` or `Connection reset`
- **Cause**: The file is not public or bucket permissions are incorrect.
- **Solution**:
  ```bash
  # Check ACL
  aws s3api get-object-acl --bucket <bucket-name> --key index.html
  
  # Manually set public-read ACL if needed
  aws s3api put-object-acl --bucket <bucket-name> --key index.html --acl public-read
  ```

### 3. Bucket name extraction fails in the workflow
The workflow filters out lines starting with `[command]` and splits at `::`. If the output format changes, adjust the extraction command accordingly.

### 4. Python script not generating `index.html`
Test it locally:
```bash
python generate_report.py
```

## License

This project is provided for educational purposes. Feel free to modify and adapt.

---

**Enjoy your automated dashboard!** 🚀
```

This version is cleaner, better structured, and ready to use as your `README.md`. Let me know if you want any sections expanded or styled differently!
