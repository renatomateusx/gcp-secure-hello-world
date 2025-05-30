/**
 * Root Terraform Configuration
 * 
 * This is the main entry point for the Terraform configuration.
 * It instantiates all the modules and passes variables between them.
 */

# Configure the Google Cloud provider
# This block sets up the Google Cloud provider with the project ID from the core_infra module
# and uses the region and zone variables for resource placement
provider "google" {
  project = module.core_infra.project_id
  region  = var.region
  zone    = var.zone
}

# Core Infrastructure Module
# Creates the foundational GCP resources:
# - GCP Project
# - Required APIs
# - Service Accounts
# - IAM permissions
module "core_infra" {
  source = "./modules/core_infra"

  project_alias      = var.project_alias
  your_name          = var.your_name
  environment        = var.environment
  billing_account_id = var.billing_account_id
  region             = var.region
  zone               = var.zone
}

# Cloud Function Module
# Deploys a serverless function with:
# - Function code and configuration
# - Service account permissions
# - API enablement
# - Environment variables
module "cloud_function" {
  source = "./modules/cloud_function"

  project_id                  = module.core_infra.project_id
  region                      = var.region
  environment                 = var.environment
  function_source_dir         = var.function_source_dir
  function_service_account_email = module.core_infra.function_service_account_email
  project_number              = module.core_infra.project_number
  project_apis_enabled        = module.core_infra.enabled_apis

  depends_on = [module.core_infra]
}

# Load Balancer Module
# Sets up a global load balancer with:
# - Backend service
# - URL map
# - Target proxy
# - Forwarding rules
# - Health checks
module "load_balancer" {
  source = "./modules/load_balancer"

  project_id    = module.core_infra.project_id
  region        = var.region
  environment   = var.environment
  function_name = module.cloud_function.function_name

  depends_on = [module.core_infra, module.cloud_function]
}

# Monitoring Module
# Creates monitoring resources:
# - Cloud Monitoring dashboards
# - Alert policies
# - Log-based metrics
# - Uptime checks
module "monitoring" {
  source = "./modules/monitoring"
  
  project_id           = module.core_infra.project_id
  function_name        = module.cloud_function.function_name
  load_balancer_name   = module.load_balancer.backend_service_name

  depends_on = [module.core_infra]
}
