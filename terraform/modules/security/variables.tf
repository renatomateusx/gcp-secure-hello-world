variable "project_id" {

  description = "The ID of the GCP project"

  type        = string

}

variable "region" {

  description = "The GCP region where the function is deployed"

  type        = string

}

variable "function_name" {

  description = "The name of the Cloud Function"

  type        = string

}

variable "function_service_account_email" {

  description = "The email of the service account used by the Cloud Function"

  type        = string

}
