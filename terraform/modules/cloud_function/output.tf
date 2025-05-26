output "function_url" {

  description = "The URL of the deployed Cloud Function"

  value       = google_cloudfunctions_function.hello_world.https_trigger_url

}

output "function_name" {

  description = "The name of the deployed Cloud Function"

  value       = google_cloudfunctions_function.hello_world.name

}

output "function_region" {

  description = "The region where the Cloud Function is deployed"

  value       = var.region

}

output "function_service_account" {

  description = "The service account used by the Cloud Function"

  value       = var.function_service_account_email

}