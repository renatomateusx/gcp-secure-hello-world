output "project_id" {

  description = "The ID of the created GCP project"

  value       = google_project.project.project_id

}

output "project_number" {

  description = "The number of the created GCP project"

  value       = google_project.project.number

}

output "function_service_account_email" {

  description = "The email of the service account created for the Cloud Function"

  value       = google_service_account.function_service_account.email

}

output "enabled_apis" {

  description = "List of APIs enabled in the project"

  value       = [for api in google_project_service.required_apis : api.service]

}
