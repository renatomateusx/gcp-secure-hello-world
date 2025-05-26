/**

 * Security Module

 * 

 * This module creates security resources including:

 * 1. IAM configurations to secure the Cloud Function

 */

# IAM binding to restrict direct access to the Cloud Function

# This ensures the function can only be invoked through the Load Balancer

resource "google_cloudfunctions_function_iam_binding" "function_no_direct_access" {

  project        = var.project_id

  region         = var.region

  cloud_function = var.function_name

  role           = "roles/cloudfunctions.invoker"

  

  # Only allow the service account to invoke the function

  # This effectively blocks direct public access

  members = [

    "serviceAccount:${var.function_service_account_email}",

  ]

}
