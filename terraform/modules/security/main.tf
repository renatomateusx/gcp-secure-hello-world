/**

 * Security Module

 * 

 * This module creates security resources including:

 * 1. IAM configurations to secure the Cloud Function

 */

# IAM binding to restrict direct access to the Cloud Function

# This ensures the function can only be invoked through the Load Balancer

# We could implement cloud armor to block direct access to the Cloud Function, b
# ut it's not needed for this project since we're using the load balancer and security policy. 
# Besides Cloud Armor is not free. For each rule, it costs $0.005 per month.

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
