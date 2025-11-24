output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}

output "server_url" {
  description = "OpenCode Server Cloud Run URL"
  value       = google_cloud_run_service.opencode_server.status[0].url
}

output "next_api_url" {
  description = "Next.js API Cloud Run URL"
  value       = google_cloud_run_service.next_api.status[0].url
}

output "server_service_name" {
  description = "OpenCode Server service name"
  value       = google_cloud_run_service.opencode_server.name
}

output "next_api_service_name" {
  description = "Next.js API service name"
  value       = google_cloud_run_service.next_api.name
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = <<-EOT
    
    ====================================
    🚀 Deployment Summary
    ====================================
    
    Project ID: ${var.project_id}
    Region: ${var.region}
    
    📦 Artifact Registry:
    ${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}
    
    🔧 OpenCode Server:
    URL: ${google_cloud_run_service.opencode_server.status[0].url}
    
    🌐 Next.js API:
    URL: ${google_cloud_run_service.next_api.status[0].url}
    
    ====================================
    Next Steps:
    1. Update your frontend to use: ${google_cloud_run_service.next_api.status[0].url}
    2. Test the API: curl ${google_cloud_run_service.next_api.status[0].url}/api/health
    3. Monitor logs: gcloud run services logs tail ${google_cloud_run_service.next_api.name} --project=${var.project_id}
    ====================================
  EOT
}
