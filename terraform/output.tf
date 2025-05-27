/**
 * Output Variables
 * 
 * This file defines the output variables that will be displayed after
 * applying the Terraform configuration.
 */

output "project_id" {
  description = "The ID of the created GCP project"
  value       = module.core_infra.project_id
}

output "project_number" {
  description = "The number of the created GCP project"
  value       = module.core_infra.project_number
}

output "function_url" {
  description = "The direct URL of the deployed Cloud Function (should return 401/403 when accessed directly)"
  value       = module.cloud_function.function_url
}

output "load_balancer_ip" {
  description = "The IP address of the Load Balancer"
  value       = module.load_balancer.load_balancer_ip
}

output "load_balancer_url" {
  description = "The URL to access the application via the Load Balancer"
  value       = module.load_balancer.load_balancer_url
}
