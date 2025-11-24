# Google Cloud Run Deployment Guide

This directory contains Terraform configuration to deploy the Strejda OpenCode application to Google Cloud Run.

## Architecture

- **OpenCode Server**: Runs the OpenCode AI server
- **Next.js API**: Provides REST API endpoints that communicate with the server
- **Artifact Registry**: Stores Docker images

## Prerequisites

1. **Google Cloud CLI** installed and authenticated
2. **Terraform** >= 1.0 installed
3. **Docker** installed for building images
4. **Google Cloud Project** created (`opencode-shopper`)

## Step-by-Step Deployment

### 1. Authenticate with Google Cloud

```bash
# Login to Google Cloud
gcloud auth login

# Set your project
gcloud config set project opencode-shopper

# Enable required APIs
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com

# Authenticate Docker with Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### 2. Initialize Terraform and Create Artifact Registry

```bash
cd terraform

# Initialize Terraform
terraform init

# Create the Artifact Registry repository first
terraform apply -target=google_artifact_registry_repository.repo

# Copy and edit your terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your configuration
```

### 3. Build and Push Docker Images

```bash
# Navigate back to project root
cd ..

# Set variables
export PROJECT_ID="opencode-shopper"
export REGION="us-central1"
export REPO="${REGION}-docker.pkg.dev/${PROJECT_ID}/strejda-repo"

# Build and push OpenCode Server
docker build -t ${REPO}/server:v1 ./server
docker push ${REPO}/server:v1

# Build and push Next.js API
docker build -t ${REPO}/next-api:v1 ./opencode-next-api
docker push ${REPO}/next-api:v1
```

### 4. Update terraform.tfvars

Edit `terraform/terraform.tfvars` with your image tags:

```hcl
project_id     = "opencode-shopper"
region         = "us-central1"
server_image   = "us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/server:v1"
next_api_image = "us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/next-api:v1"
```

### 5. Deploy to Cloud Run

```bash
cd terraform

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Note the output URLs for your services
```

### 6. Test Your Deployment

```bash
# Get the API URL from Terraform output
API_URL=$(terraform output -raw next_api_url)

# Test the health endpoint
curl ${API_URL}/api/health

# Test the chat endpoint
curl -X POST ${API_URL}/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, OpenCode!"}'
```

## Managing Your Deployment

### View Logs

```bash
# View Next.js API logs
gcloud run services logs tail opencode-next-api --project=opencode-shopper

# View Server logs
gcloud run services logs tail opencode-server --project=opencode-shopper
```

### Update Services

When you make changes to your code:

```bash
# 1. Build and push new images with a new tag (e.g., v2)
docker build -t ${REPO}/server:v2 ./server
docker push ${REPO}/server:v2

# 2. Update terraform.tfvars with new image tag
# server_image = "us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/server:v2"

# 3. Apply Terraform changes
cd terraform
terraform apply
```

### Scale Configuration

Edit `terraform/variables.tf` or override in `terraform.tfvars`:

```hcl
server_cpu    = "2000m"  # 2 vCPUs
server_memory = "1Gi"    # 1 GB RAM
```

Then apply:
```bash
terraform apply
```

### Monitor Costs

```bash
# View current month's costs
gcloud billing accounts list
gcloud billing projects describe opencode-shopper
```

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | `opencode-shopper` |
| `region` | GCP Region | `us-central1` |
| `server_image` | Docker image for server | Required |
| `next_api_image` | Docker image for API | Required |
| `server_cpu` | Server CPU allocation | `1000m` |
| `server_memory` | Server memory allocation | `512Mi` |
| `next_api_cpu` | API CPU allocation | `1000m` |
| `next_api_memory` | API memory allocation | `512Mi` |
| `allow_public_access` | Allow public access | `true` |

## Troubleshooting

### Permission Denied Errors

```bash
# Ensure you have the necessary IAM roles
gcloud projects add-iam-policy-binding opencode-shopper \
  --member="user:YOUR_EMAIL@example.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding opencode-shopper \
  --member="user:YOUR_EMAIL@example.com" \
  --role="roles/artifactregistry.admin"
```

### Image Pull Errors

```bash
# Verify images exist
gcloud artifacts docker images list us-central1-docker.pkg.dev/opencode-shopper/strejda-repo

# Grant Cloud Run service account access
gcloud projects add-iam-policy-binding opencode-shopper \
  --member="serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/artifactregistry.reader"
```

### Service Not Responding

```bash
# Check service status
gcloud run services describe opencode-server --region=us-central1

# View recent logs
gcloud run services logs read opencode-server --limit=50 --region=us-central1
```

## Clean Up

To destroy all resources:

```bash
cd terraform
terraform destroy
```

**Warning**: This will delete all Cloud Run services and the Artifact Registry repository.

## Cost Optimization Tips

1. **Scale to Zero**: Services automatically scale to zero when not in use (already configured)
2. **Right-size Resources**: Start with smaller CPU/memory and scale up if needed
3. **Use Regional Deployment**: Keep services in the same region to minimize egress costs
4. **Monitor Usage**: Set up budget alerts in Google Cloud Console

## Security Best Practices

1. **Restrict Public Access**: Set `allow_public_access = false` and implement authentication
2. **Use Secret Manager**: Store sensitive configuration in Google Secret Manager
3. **Enable Binary Authorization**: Ensure only verified images can be deployed
4. **Set up Cloud Armor**: Add DDoS protection and WAF rules

## Next Steps

1. Set up a custom domain with Cloud Run
2. Configure Cloud CDN for static assets
3. Implement Cloud Monitoring and Alerting
4. Set up CI/CD pipeline with Cloud Build
5. Add environment-specific deployments (dev/staging/prod)
