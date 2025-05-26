/**
 * Cloud Function Module
 *
 * This module creates a Cloud Function that returns "Hello World" for GET requests
 * and rejects other HTTP methods. It includes the storage bucket for the function code,
 * the function itself, and IAM permissions.
 */

# Create a storage bucket for the function source code
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-function-source"
  location = var.region
  uniform_bucket_level_access = true

  # Force destroy for assessment purposes, but consider false for production
  force_destroy = true

  # Recommended security settings
  versioning {
    enabled = true
  }
}

# Create a ZIP archive of the function source code
data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = var.function_source_dir
  output_path = "${path.module}/function_source.zip"
}

# Upload the function source code to the bucket
resource "google_storage_bucket_object" "function_source" {
  name   = "function-source-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_source.output_path
}

# Create the Cloud Function
resource "google_cloudfunctions_function" "hello_world" {
  name        = "hello-world-function"
  description = "A simple Hello World function"
  runtime     = "python39"

  # Source code configuration
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_source.name
  entry_point          = "hello_world"  # Function name in the source code

  # Trigger configuration - HTTP trigger
  trigger_http = true

  # Resource configuration
  available_memory_mb = 256
  timeout            = 60
  min_instances      = 0
  max_instances      = 3  # Auto-scaling for high availability

  # Use the service account created in the core_infra module
  service_account_email = var.function_service_account_email

  # Environment variables
  environment_variables = {
    PYTHONUNBUFFERED = "true"
  }

  # Labels for resource organization
  labels = {
    environment = var.environment
    terraform   = "true"
    function    = "hello-world"
  }

  # Build configuration
  build_environment_variables = {
    GOOGLE_FUNCTION_SOURCE = "main.py"
  }

  # Depends on APIs being enabled
  depends_on = [var.project_apis_enabled]
}

# Allow the Load Balancer to invoke the function
resource "google_cloudfunctions_function_iam_binding" "function_invoker" {
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  members        = [
    "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com",
    "serviceAccount:${var.function_service_account_email}",
    "serviceAccount:service-${var.project_number}@serverless-robot-prod.iam.gserviceaccount.com"
  ]
}

# Deny direct access to the function
resource "google_cloudfunctions_function_iam_binding" "function_deny_all" {
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  members        = []
}

# Allow access to Serverless NEG
resource "google_cloudfunctions_function_iam_member" "neg_invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

# Allow access to your own service account
resource "google_cloudfunctions_function_iam_member" "self_invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.function_service_account_email}"
}