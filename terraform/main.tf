/**
 * Root Terraform Configuration
 * 
 * This is the main entry point for the Terraform configuration.
 * It instantiates all the modules and passes variables between them.
 */


# Configure the Google Cloud provider
provider "google" {
  project = module.core_infra.project_id
  region  = var.region
  zone    = var.zone
}

# Create the core infrastructure (project, APIs, service accounts)
module "core_infra" {
  source = "./modules/core_infra"

  project_alias      = var.project_alias
  your_name          = var.your_name
  environment        = var.environment
  billing_account_id = var.billing_account_id
  region             = var.region
  zone               = var.zone
}

# Create the Cloud Function
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

# Create the Load Balancer
module "load_balancer" {
  source = "./modules/load_balancer"

  project_id    = module.core_infra.project_id
  region        = var.region
  environment   = var.environment
  function_name = module.cloud_function.function_name

  depends_on = [module.core_infra, module.cloud_function]
}

# Optional: Create monitoring resources
module "monitoring" {
  source = "./modules/monitoring"
  
  project_id           = module.core_infra.project_id
  function_name        = module.cloud_function.function_name
  load_balancer_name   = module.load_balancer.backend_service_name

  depends_on = [module.core_infra]
}
