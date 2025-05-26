variable "project_id" {

  description = "The ID of the GCP project"

  type        = string

}

variable "function_name" {

  description = "The name of the Cloud Function"

  type        = string

}

variable "load_balancer_name" {

  description = "The name of the Load Balancer URL map"

  type        = string

}
