# OpenCode Chat Application

A full-stack chat application powered by OpenCode and Big Pickle, separated into backend and frontend services for independent deployment.

## Architecture

This application is split into three separate services:

### Server: `server/`
- **Technology**: OpenCode server
- **Deployment**: Docker container
- **Purpose**: Core AI chat server that processes messages, AI agent configured by json.
- **Dependencies**: OpenCode server dependencies

### Backend: `opencode-next-api/`
- **Technology**: Next.js API server
- **Deployment**: Docker container
- **Purpose**: Provides `/api/chat` endpoint that proxies requests to the OpenCode server
- **Dependencies**: `@opencode-ai/sdk`, `next`

### Frontend: `front-end-ui/`
- **Technology**: Next.js React application
- **Deployment**: Netlify (static build)
- **Purpose**: User interface for chat application
- **Dependencies**: `next`, `react`, `react-dom`, `tailwindcss`


## Service Dependencies

**Important**: All three services must be running for the application to work correctly:

1. **Server** - The OpenCode AI server that processes chat messages
2. **Backend API** - The Next.js API that proxies requests to the server
3. **Frontend** - The React UI that users interact with

The backend API (`opencode-next-api/app/api/chat/route.ts`) makes HTTP calls to the OpenCode server, so the server must be accessible at the configured URL.

## Local Development

For local development, you can use the `docker-compose.yml` file to build and run all the necessary services. This is the recommended way to set up your development environment.

### Setup

1. **Configure environment variables:**
   ```bash
   cp server/.env.example server/.env
   ```
   Edit `server/.env` and add your OpenAI API key:
   ```
   OPENCODE_MODEL=openai/gpt-4o
   OPENAI_API_KEY=sk-proj-your-api-key-here
   ```

2. **Start all services:**
   ```bash
   docker-compose up --build
   ```

The services will be available at:
- Frontend: http://localhost:3001
- API: http://localhost:3000
- OpenCode Server: http://localhost:4096

## Production Deployment

For production, the `terraform/` directory contains all the necessary infrastructure-as-code to deploy the backend services to Google Cloud Platform. The Terraform scripts will provision all the required resources, such as virtual machines, load balancers, and networking configurations.

The static web frontend is not managed by Terraform and must be manually configured and deployed on Netlify.

### Deployment Script (`deploy.sh`)

The `deploy.sh` script automates the entire backend deployment process. It performs the following steps:

1.  **Builds Docker Images**: Creates Docker images for the `server` and `opencode-next-api` services.
2.  **Pushes to Artifact Registry**: Pushes the built Docker images to Google Cloud Artifact Registry.
3.  **Runs Terraform Apply**: Executes `terraform apply` using the Terraform configurations in the `terraform/` directory, deploying the services to Google Cloud Run.

#### Prerequisites

1. Install required tools: `docker`, `gcloud`, `terraform`, `git`
2. Authenticate with Google Cloud:
   ```bash
   gcloud auth login
   gcloud config set project opencode-shopper
   ```
3. Configure Terraform variables:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` and add your OpenAI API key:
   ```hcl
   openai_api_key = "sk-proj-your-actual-api-key-here"
   opencode_model = "openai/gpt-4o"
   ```

#### Run Deployment

```bash
./deploy.sh
```

See `terraform/README.md` for detailed deployment instructions.
