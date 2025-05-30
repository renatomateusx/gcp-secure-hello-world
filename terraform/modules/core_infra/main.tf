/**
 * Core Infrastructure Module
 * 
 * This module creates the GCP project and enables required APIs.
 * It follows the naming convention required in the assessment:
 * smt-the-{env}-{yourname}-{random4char}
 * 
 * The module sets up:
 * - GCP Project
 * - Required APIs
 * - Service Accounts
 * - IAM Permissions
 */

# Bootstrap provider configuration
# Used for initial project creation before the main provider can be configured
provider "google" {
  alias  = "bootstrap"
  region = var.region
  zone   = var.zone
}

# Random string generator
# Creates a unique 4-character suffix for the project ID
# Uses keepers to ensure the same suffix is used across applies
resource "random_string" "project_suffix" {
  length  = 4
  special = false
  upper   = false
  keepers = {
    environment = var.environment
    your_name   = var.your_name
  }
}

# GCP Project creation
# Creates a new project with the specified configuration
# Includes labels for better organization and resource management
resource "google_project" "project" {
  provider            = google.bootstrap
  name                = "SMT Take Home Exercise"
  project_id          = "smt-the-${var.environment}-${var.your_name}-${random_string.project_suffix.result}"
  billing_account     = var.billing_account_id
  auto_create_network = true

  labels = {
    environment = var.environment
    purpose     = "assessment"
    terraform   = "true"
  }

  deletion_policy = "DELETE"
}

# Enable required GCP APIs
# Enables all necessary APIs for the project to function
# Each API is enabled with disable_on_destroy = false to prevent accidental disabling
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

# Cloud Function Service Account
# Creates a dedicated service account for the Cloud Function
# Used for function execution and authentication
resource "google_service_account" "function_service_account" {
  project      = google_project.project.project_id
  account_id   = "hello-world-function-sa"
  display_name = "Hello World Function Service Account"
  description  = "Service account for the Hello World Cloud Function"
}

# Function Invoker Permission
# Grants the function service account permission to invoke Cloud Functions
resource "google_project_iam_member" "function_permissions" {
  project = google_project.project.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.function_service_account.email}"
}

# Storage Object Viewer Permission
# Allows the Cloud Functions service account to read storage objects
resource "google_project_iam_member" "function_storage_viewer" {
  project = google_project.project.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Cloud Functions Developer Role
# Grants the service account permission to develop and deploy functions
resource "google_project_iam_member" "function_developer" {
  project = google_project.project.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Artifact Registry Writer Role
# Allows the Cloud Build service account to write to Artifact Registry
resource "google_project_iam_member" "build_artifact_writer" {
  project = google_project.project.project_id
  role    = "roles/artifactregistry.createOnPushWriter"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Logging Writer Role
# Enables the Cloud Build service account to write logs
resource "google_project_iam_member" "build_log_writer" {
  project = google_project.project.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Storage Object Admin Role
# Grants full control over storage objects to the Cloud Build service account
resource "google_project_iam_member" "build_storage_admin" {
  project = google_project.project.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}
