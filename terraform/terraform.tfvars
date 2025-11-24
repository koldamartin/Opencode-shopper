# GCP Project Configuration
project_id = "opencode-shopper"
region     = "us-central1"

# Docker Images (always uses 'latest' tag - automatically picks up new builds)
# Format: REGION-docker.pkg.dev/PROJECT_ID/REPO_NAME/IMAGE_NAME:TAG
server_image   = "us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/server:latest"
next_api_image = "us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/next-api:latest"

# Resource Allocation (optional - defaults are set in variables.tf)
# server_cpu       = "1000m"  # 1 vCPU
# server_memory    = "512Mi"  # 512 MB
# next_api_cpu     = "1000m"
# next_api_memory  = "512Mi"

# Access Control
allow_public_access = true
