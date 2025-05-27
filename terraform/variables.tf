/**
 * Input Variables
 * 
 * This file defines all input variables that can be used to customize
 * the Terraform configuration. Variables can be set via:
 * - Command line arguments
 * - Environment variables
 * - Variable definition files (*.tfvars)
 */

variable "environment" {

  description = "Environment name (dev, tst, prd)"

  type        = string

  validation {

    condition     = contains(["dev", "tst", "prd"], var.environment)

    error_message = "Environment must be one of: dev, tst, prd."

  }

}

variable "initial_project" {
    description = "Project name"
    type = string
    default = "smt-the-dev-rsantos-i5qi"
}

variable "your_name" {

  description = "Your name to be included in the project ID"

  type        = string

  validation {

    condition     = length(var.your_name) > 2 && length(var.your_name) <= 10

    error_message = "Your name must be between 3 and 10 characters."

  }

}

variable "billing_account_id" {

  description = "The ID of the billing account to associate with the project"

  type        = string

  sensitive   = true

  default = "019A84-EB6FF8-7E7A66"

}

variable "region" {

  description = "The GCP region to deploy resources to"

  type        = string

  default     = "us-central1"

}

variable "zone" {

  description = "The GCP zone within the region to deploy zonal resources"

  type        = string

  default     = "us-central1-a"

}

variable "function_source_dir" {

  description = "Directory containing the function source code"

  type        = string

  default     = "../function"

}
