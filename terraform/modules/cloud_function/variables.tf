variable "project_id" {

  description = "The ID of the GCP project"

  type        = string

}

variable "region" {

  description = "The GCP region to deploy the function to"

  type        = string

}

variable "environment" {

  description = "Environment name (dev, tst, prd)"

  type        = string

}

variable "function_source_dir" {

  description = "Directory containing the function source code"

  type        = string

}

variable "function_service_account_email" {

  description = "Email of the service account for the Cloud Function"

  type        = string

}

variable "project_apis_enabled" {

  description = "Dependency variable to ensure APIs are enabled before creating the function"

  type        = any

}

variable "project_number" {
  description = "The numeric project ID"
  type        = string
}