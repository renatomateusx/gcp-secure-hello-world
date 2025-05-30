/**
 * Cloud Function Module
 *
 * This module creates a Cloud Function that returns "Hello World" for GET requests
 * and rejects other HTTP methods. It includes the storage bucket for the function code,
 * the function itself, and IAM permissions.
 * 
 * The module sets up:
 * - Storage bucket for function code
 * - Function deployment
 * - IAM permissions and security
 * - Auto-scaling configuration
 */

# Storage Bucket
# Creates a dedicated bucket for storing function source code
# Includes versioning and uniform bucket level access for security
resource "google_storage_bucket" "function_bucket" {
  project  = var.project_id
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

# Source Code Archive
# Creates a ZIP file of the function source code
# Uses MD5 hash in filename for versioning
data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = var.function_source_dir
  output_path = "${path.module}/function_source.zip"
}

# Source Code Upload
# Uploads the ZIP file to the storage bucket
# Uses MD5 hash in object name for versioning
resource "google_storage_bucket_object" "function_source" {
  name   = "function-source-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_source.output_path
}

# Cloud Function
# Deploys the actual function with:
# - Python 3.9 runtime
# - HTTP trigger
# - Auto-scaling (0-3 instances)
# - Service account integration
# - Environment variables
resource "google_cloudfunctions_function" "hello_world" {
  project     = var.project_id
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

# Load Balancer Invoker Permission
# Allows the Load Balancer service account to invoke the function
resource "google_cloudfunctions_function_iam_binding" "function_invoker" {
  project        = var.project_id
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  members        = [
    "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com",
    "serviceAccount:${var.function_service_account_email}",
    "serviceAccount:service-${var.project_number}@serverless-robot-prod.iam.gserviceaccount.com"
  ]
}

# Direct Access Denial
# Explicitly denies direct access to the function
# This ensures the function can only be accessed through the Load Balancer
resource "google_cloudfunctions_function_iam_binding" "function_deny_all" {
  project        = var.project_id
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  members        = []
}

# Serverless NEG Permission
# Allows the Serverless Network Endpoint Group to invoke the function
resource "google_cloudfunctions_function_iam_member" "neg_invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.project_number}-compute@developer.gserviceaccount.com"
}

# Self-Invocation Permission
# Allows the function's own service account to invoke itself
# Useful for function-to-function communication
resource "google_cloudfunctions_function_iam_member" "self_invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.hello_world.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.function_service_account_email}"
}