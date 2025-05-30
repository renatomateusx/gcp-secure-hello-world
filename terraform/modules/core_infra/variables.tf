variable "environment" {

  description = "Environment name (dev, tst, prd)"

  type        = string

  validation {

    condition     = contains(["dev", "tst", "prd"], var.environment)

    error_message = "Environment must be one of: dev, tst, prd."

  }

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

variable "project_alias" {

  description = "The alias for the project"

  type        = string

}
