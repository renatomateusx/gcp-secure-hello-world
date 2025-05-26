variable "project_id" {

  description = "The ID of the GCP project"

  type        = string

}

variable "region" {

  description = "The GCP region where the function is deployed"

  type        = string

}

variable "environment" {

  description = "Environment name (dev, tst, prd)"

  type        = string

}

variable "function_name" {

  description = "The name of the Cloud Function"

  type        = string

}
