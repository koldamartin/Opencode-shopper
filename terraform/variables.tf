variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
  default     = "opencode-shopper"
}

variable "region" {
  description = "The GCP region to deploy to"
  type        = string
  default     = "us-central1"
}

variable "server_image" {
  description = "The Docker image for the OpenCode server (e.g., us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/server:v1)"
  type        = string
}

variable "next_api_image" {
  description = "The Docker image for the Next.js API (e.g., us-central1-docker.pkg.dev/opencode-shopper/strejda-repo/next-api:v1)"
  type        = string
}

variable "server_cpu" {
   description = "CPU allocation for OpenCode server (in millicores) - optimized for free tier"
   type        = string
   default     = "256m"
}

variable "server_memory" {
   description = "Memory allocation for OpenCode server - optimized for free tier"
   type        = string
   default     = "512Mi"
}

variable "next_api_cpu" {
   description = "CPU allocation for Next.js API (in millicores) - optimized for free tier"
   type        = string
   default     = "256m"
}

variable "next_api_memory" {
   description = "Memory allocation for Next.js API - optimized for free tier"
   type        = string
   default     = "256Mi"
}

variable "allow_public_access" {
  description = "Allow unauthenticated public access to services"
  type        = bool
  default     = true
}
