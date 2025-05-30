/**
 * Output Variables
 * 
 * This file defines the output variables that will be displayed after
 * applying the Terraform configuration.
 * These outputs are useful for:
 * - Getting important resource information
 * - Accessing deployed resources
 * - Sharing information with other systems
 */

# Project ID output
# Returns the unique identifier of the GCP project
# Used for referencing the project in other configurations
output "project_id" {
  description = "The ID of the created GCP project"
  value       = module.core_infra.project_id
}

# Project number output
# Returns the numeric identifier of the GCP project
# Used for certain GCP APIs and services
output "project_number" {
  description = "The number of the created GCP project"
  value       = module.core_infra.project_number
}

# Function URL output
# Returns the direct URL to access the Cloud Function
# Note: Direct access is restricted (401/403) for security
output "function_url" {
  description = "The direct URL of the deployed Cloud Function (should return 401/403 when accessed directly)"
  value       = module.cloud_function.function_url
}

# Load Balancer IP output
# Returns the public IP address of the Load Balancer
# Used for DNS configuration and direct IP access
output "load_balancer_ip" {
  description = "The IP address of the Load Balancer"
  value       = module.load_balancer.load_balancer_ip
}

# Load Balancer URL output
# Returns the public URL to access the application
# This is the main entry point for users
output "load_balancer_url" {
  description = "The URL to access the application via the Load Balancer"
  value       = module.load_balancer.load_balancer_url
}
