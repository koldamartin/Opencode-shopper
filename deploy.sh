#!/bin/bash

################################################################################
#
# STREJDA DEPLOYMENT SCRIPT
#
# This script automates the complete deployment workflow:
# 1. Builds Docker images for the server and next-api services
# 2. Pushes them to Google Cloud Artifact Registry
# 3. Runs terraform apply to deploy the services to Cloud Run
#
################################################################################

set -e  # Exit on any error

################################################################################
# SETUP & CONFIGURATION
################################################################################

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Configuration
PROJECT_ID="opencode-shopper"
REGION="us-central1"
REGISTRY="$REGION-docker.pkg.dev"
ARTIFACT_REPO="strejda-repo"
GIT_COMMIT=$(git -C "$SCRIPT_DIR" rev-parse --short HEAD)
IMAGE_TAG="$GIT_COMMIT"

# Full image paths
SERVER_IMAGE="$REGISTRY/$PROJECT_ID/$ARTIFACT_REPO/server:$IMAGE_TAG"
NEXT_API_IMAGE="$REGISTRY/$PROJECT_ID/$ARTIFACT_REPO/next-api:$IMAGE_TAG"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

################################################################################
# HELPER FUNCTIONS
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for required commands
    local required_tools=("docker" "gcloud" "terraform" "git")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "Required tool not found: $tool"
            return 1
        fi
    done
    
    log_success "All prerequisites found"
}

authenticate_docker() {
    log_info "Configuring Docker authentication for Artifact Registry..."
    
    # Configure docker to authenticate with gcloud
    gcloud auth configure-docker "$REGISTRY" --quiet
    
    log_success "Docker authentication configured"
}

build_server_image() {
    log_info "Building server Docker image..."
    
    local server_dir="$SCRIPT_DIR/server"
    
    if [ ! -d "$server_dir" ]; then
        log_error "Server directory not found: $server_dir"
        return 1
    fi
    
    docker build \
        -t "$SERVER_IMAGE" \
        -f "$server_dir/Dockerfile" \
        "$server_dir"
    
    log_success "Server image built: $SERVER_IMAGE"
}

build_next_api_image() {
    log_info "Building next-api Docker image..."
    
    local next_api_dir="$SCRIPT_DIR/opencode-next-api"
    
    if [ ! -d "$next_api_dir" ]; then
        log_error "Next API directory not found: $next_api_dir"
        return 1
    fi
    
    docker build \
        -t "$NEXT_API_IMAGE" \
        -f "$next_api_dir/Dockerfile" \
        "$next_api_dir"
    
    log_success "Next API image built: $NEXT_API_IMAGE"
}

push_server_image() {
    log_info "Pushing server image to Artifact Registry..."
    docker push "$SERVER_IMAGE"
    log_success "Server image pushed: $SERVER_IMAGE"
}

push_next_api_image() {
    log_info "Pushing next-api image to Artifact Registry..."
    docker push "$NEXT_API_IMAGE"
    log_success "Next API image pushed: $NEXT_API_IMAGE"
}

run_terraform_apply() {
    log_info "Running terraform apply..."
    
    local terraform_dir="$SCRIPT_DIR/terraform"
    
    if [ ! -d "$terraform_dir" ]; then
        log_error "Terraform directory not found: $terraform_dir"
        return 1
    fi
    
    cd "$terraform_dir"
    
    terraform apply \
        -var="server_image=$SERVER_IMAGE" \
        -var="next_api_image=$NEXT_API_IMAGE" \
        -auto-approve
    
    cd "$SCRIPT_DIR"
    
    log_success "Terraform apply completed"
}

print_deployment_summary() {
    echo ""
    log_success "================================"
    log_success "DEPLOYMENT COMPLETED SUCCESSFULLY"
    log_success "================================"
    echo ""
    echo -e "${BLUE}Deployment Details:${NC}"
    echo "  Git Commit: $GIT_COMMIT"
    echo "  Image Tag: $IMAGE_TAG"
    echo "  Server Image: $SERVER_IMAGE"
    echo "  Next API Image: $NEXT_API_IMAGE"
    echo ""
    echo -e "${BLUE}Services Deployed to:${NC}"
    echo "  Region: $REGION"
    echo "  Project: $PROJECT_ID"
    echo ""
}

print_usage() {
    cat << 'EOF'
================================================================================
STREJDA DEPLOYMENT SCRIPT - USAGE GUIDE
================================================================================

This script automates the complete deployment workflow for the Strejda project.

WHAT THIS SCRIPT DOES:
1. Checks all prerequisites (docker, gcloud, terraform, git)
2. Configures Docker authentication with Google Cloud Artifact Registry
3. Builds Docker images for both services (server and next-api)
4. Pushes images to Google Cloud Artifact Registry
5. Runs Terraform to deploy services to Cloud Run

PREREQUISITES:
- Docker installed and running
- gcloud CLI installed and authenticated: gcloud auth login
- Terraform installed
- Git installed
- Access to Google Cloud Project: opencode-shopper

SETUP (ONE TIME ONLY):
1. Authenticate with Google Cloud:
   $ gcloud auth login
   $ gcloud config set project opencode-shopper

2. Ensure Artifact Registry repository exists (created by terraform manually first time):
   $ terraform -chdir=terraform init
   $ terraform -chdir=terraform apply  # This creates the Artifact Registry

RUNNING THE DEPLOYMENT:

  $ ./deploy.sh

That's it! The script will:
- Build both Docker images using the current git commit hash as the version tag
- Push them to Artifact Registry
- Deploy them to Cloud Run using Terraform

EXAMPLE OUTPUT:
  [INFO] Checking prerequisites...
  [SUCCESS] All prerequisites found
  [INFO] Building server Docker image...
  [SUCCESS] Server image built: us-central1-docker.pkg.dev/.../server:a1b2c3d
  [INFO] Building next-api Docker image...
  [SUCCESS] Next API image built: us-central1-docker.pkg.dev/.../next-api:a1b2c3d
  [INFO] Pushing server image to Artifact Registry...
  [SUCCESS] Server image pushed: us-central1-docker.pkg.dev/.../server:a1b2c3d
  [INFO] Pushing next-api image to Artifact Registry...
  [SUCCESS] Next API image pushed: us-central1-docker.pkg.dev/.../next-api:a1b2c3d
  [INFO] Running terraform apply...
  [SUCCESS] Terraform apply completed
  [SUCCESS] DEPLOYMENT COMPLETED SUCCESSFULLY

TROUBLESHOOTING:

Q: "docker: command not found"
A: Install Docker from https://docs.docker.com/install/

Q: "gcloud: command not found"
A: Install Google Cloud SDK from https://cloud.google.com/sdk/docs/install

Q: "Authentication required"
A: Run: gcloud auth login

Q: "Permission denied"
A: Make sure the script is executable: chmod +x ./deploy.sh

Q: "Dockerfile not found"
A: Ensure your Dockerfile exists in:
   - server/Dockerfile
   - opencode-next-api/Dockerfile

Q: "Docker build fails with compilation errors"
A: Fix the errors in your application code first, then retry

Q: "Terraform apply fails - invalid image reference"
A: Ensure the Docker images were successfully pushed to Artifact Registry

MANUAL WORKFLOW (If you prefer not to use this script):

1. Build images:
   $ docker build -t us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/server:TAG ./server
   $ docker build -t us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/next-api:TAG ./opencode-next-api

2. Push images:
   $ gcloud auth configure-docker us-central1-docker.pkg.dev
   $ docker push us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/server:TAG
   $ docker push us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/next-api:TAG

3. Deploy with Terraform:
   $ cd terraform
   $ terraform apply \
     -var="server_image=us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/server:TAG" \
     -var="next_api_image=us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/next-api:TAG"

ENVIRONMENT VARIABLES (Optional):
You can override default values by setting environment variables:
  PROJECT_ID - Google Cloud Project ID (default: opencode-shopper)
  REGION - GCP Region (default: us-central1)

Example:
  PROJECT_ID="my-project" REGION="europe-west1" ./deploy.sh

================================================================================
EOF
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    echo ""
    log_info "Starting Strejda Deployment Process..."
    echo ""
    
    # Parse command line arguments
    case "${1:-}" in
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            ;;
    esac
    
    # Run all deployment steps
    check_prerequisites || exit 1
    authenticate_docker || exit 1
    build_server_image || exit 1
    build_next_api_image || exit 1
    push_server_image || exit 1
    push_next_api_image || exit 1
    run_terraform_apply || exit 1
    print_deployment_summary
}

# Run main function
main "$@"
