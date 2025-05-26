/**

 * Core Infrastructure Module

 * 

 * This module creates the GCP project and enables required APIs.

 * It follows the naming convention required in the assessment:

 * smt-the-{env}-{yourname}-{random4char}

 */

# Generate random 4 characters for project ID suffix

resource "random_string" "project_suffix" {

  length  = 4

  special = false

  upper   = false

  numeric = true

}

# Create the GCP project

resource "google_project" "project" {

  name            = "SMT Take Home Exercise"

  project_id      = "smt-the-${var.environment}-${var.your_name}-${random_string.project_suffix.result}"

  billing_account = var.billing_account_id

  # Skip delete protection for assessment purposes, but would be recommended for production

  # auto_create_network = false # Uncomment to skip default network creation

  labels = {

    environment = var.environment

    purpose     = "assessment"

    terraform   = "true"

  }

}

# T Enable required APIs

resource "google_project_service" "required_apis" {

  for_each = toset([

    "cloudfunctions.googleapis.com",     # Cloud Functions API

    "cloudbuild.googleapis.com",         # Cloud Build API

    "artifactregistry.googleapis.com",   # Artifact Registry API

    "compute.googleapis.com",            # Compute Engine API

    "iam.googleapis.com",                # Identity and Access Management API

    "secretmanager.googleapis.com",      # Secret Manager API

    "logging.googleapis.com",            # Cloud Logging API

    "monitoring.googleapis.com",         # Cloud Monitoring API

    "cloudresourcemanager.googleapis.com", # Resource Manager API

    "serviceusage.googleapis.com",       # Service Usage API

    "run.googleapis.com",                # Cloud Run API

    "vpcaccess.googleapis.com",          # VPC Access API

    "cloudscheduler.googleapis.com",     # Cloud Scheduler API

  ])

  project            = google_project.project.project_id

  service            = each.key

  disable_on_destroy = false

}

# Creating a service account for the Cloud Function

resource "google_service_account" "function_service_account" {

  project      = google_project.project.project_id

  account_id   = "hello-world-function-sa"

  display_name = "Hello World Function Service Account"

  description  = "Service account for the Hello World Cloud Function"

}

# To Grant minimal permissions to the service account

resource "google_project_iam_member" "function_permissions" {

  project = google_project.project.project_id

  role    = "roles/cloudfunctions.invoker"

  member  = "serviceAccount:${google_service_account.function_service_account.email}"

}

# Grant Storage Object Viewer permission to the Cloud Functions service account
resource "google_project_iam_member" "function_storage_viewer" {
  project = google_project.project.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Grant Cloud Functions Developer role to the Cloud Functions service account
resource "google_project_iam_member" "function_developer" {
  project = google_project.project.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Grant Artifact Registry Writer role to the Cloud Build service account
resource "google_project_iam_member" "build_artifact_writer" {
  project = google_project.project.project_id
  role    = "roles/artifactregistry.createOnPushWriter"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Grant Logging Writer role to the Cloud Build service account
resource "google_project_iam_member" "build_log_writer" {
  project = google_project.project.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Grant Storage Object Admin role to the Cloud Build service account
resource "google_project_iam_member" "build_storage_admin" {
  project = google_project.project.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}
