/**
 * Input Variables
 * 
 * This file defines all input variables that can be used to customize
 * the Terraform configuration. Variables can be set via:
 * - Command line arguments
 * - Environment variables
 * - Variable definition files (*.tfvars)
 */

# Environment variable
# Defines the deployment environment (dev, tst, prd)
# Used for resource naming and environment-specific configurations
variable "environment" {
  description = "Environment name (dev, tst, prd)"
  type        = string
  validation {
    condition     = contains(["dev", "tst", "prd"], var.environment)
    error_message = "Environment must be one of: dev, tst, prd."
  }
}

# Your name variable
# Used to create unique project IDs and resource names
# Must be between 3 and 10 characters
variable "your_name" {
  description = "Your name to be included in the project ID"
  type        = string
  validation {
    condition     = length(var.your_name) > 2 && length(var.your_name) <= 10
    error_message = "Your name must be between 3 and 10 characters."
  }
}

# Initial project variable
# Default project name for initial setup
# Used when creating new GCP resources
variable "initial_project" {
    description = "Project name"
    type = string
    default = "smt-the-dev-rsantos-i5qi"
}

# Billing account ID
# Sensitive variable that stores the GCP billing account ID
# Used to associate costs with the project
variable "billing_account_id" {
  description = "The ID of the billing account to associate with the project"
  type        = string
  sensitive   = true
  default = "019A84-EB6FF8-7E7A66"
}

# Region variable
# Defines the GCP region for resource deployment
# Defaults to us-central1
variable "region" {
  description = "The GCP region to deploy resources to"
  type        = string
  default     = "us-central1"
}

# Zone variable
# Defines the specific zone within the region
# Used for zonal resources like compute instances
variable "zone" {
  description = "The GCP zone within the region to deploy zonal resources"
  type        = string
  default     = "us-central1-a"
}

# Function source directory
# Path to the Cloud Function source code
# Used by the cloud_function module to deploy the function
variable "function_source_dir" {
  description = "Directory containing the function source code"
  type        = string
  default     = "../function"
}

# Project alias
# Used to create a friendly name for the project
# Helps identify the project in the GCP console
variable "project_alias" {
  description = "The alias for the project"
  type        = string
  default     = "mygcphelloworldproject"
}
