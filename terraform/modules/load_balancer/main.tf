/**
 * Load Balancer Module
 *
 * This module creates a global HTTP(S) Load Balancer with a Serverless NEG
 * that points to the Cloud Function. It includes backend services,
 * URL maps, and forwarding rules.
 * 
 * The module sets up:
 * - Serverless Network Endpoint Group (NEG)
 * - Security policies
 * - Backend service
 * - URL routing
 * - HTTP proxy
 * - Global forwarding rules
 */

# Serverless NEG
# Creates a Network Endpoint Group that connects to the Cloud Function
# This allows the Load Balancer to route traffic to the serverless function
resource "google_compute_region_network_endpoint_group" "function_neg" {
  project               = var.project_id
  name                  = "hello-world-function-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_function {
    function = var.function_name
  }
}

# Security Policy
# Defines rules for traffic filtering and access control
# Currently allows all traffic but can be customized for production
resource "google_compute_security_policy" "function_security_policy" {
  project               = var.project_id
  name = "hello-world-security-policy"

  # Rule that allows all requests
  rule {
    action      = "allow"
    description = "Allow all requests"
    priority    = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }

  # Default rule that denies all other requests
  rule {
    action      = "deny(403)"
    description = "Default rule, higher priority overrides it"
    priority    = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

# Backend Service
# Configures how traffic is routed to the Cloud Function
# Includes timeout settings and logging configuration
resource "google_compute_backend_service" "function_backend" {
  project     = var.project_id
  name        = "hello-world-backend"
  description = "Backend service for the Hello World function"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30

  # Connect to the Serverless NEG
  backend {
    group = google_compute_region_network_endpoint_group.function_neg.id
  }

  log_config {
    enable = true
  }
}

# URL Map
# Defines routing rules for incoming requests
# Currently routes all traffic to the backend service
resource "google_compute_url_map" "function_url_map" {
  project         = var.project_id
  name            = "hello-world-url-map"
  description     = "URL map for the Hello World function"
  default_service = google_compute_backend_service.function_backend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.function_backend.id

    path_rule {
      paths   = ["/helloWorld"]
      service = google_compute_backend_service.function_backend.id
    }
  }
}

# HTTP Proxy
# Creates a proxy that uses the URL map for routing
# Acts as an intermediary between clients and the backend
resource "google_compute_target_http_proxy" "function_http_proxy" {
  project     = var.project_id
  name        = "hello-world-http-proxy"
  description = "HTTP proxy for the Hello World function"
  url_map     = google_compute_url_map.function_url_map.id
}

# Global Forwarding Rule
# Creates the entry point for incoming traffic
# Routes traffic to the HTTP proxy on port 80
resource "google_compute_global_forwarding_rule" "function_forwarding_rule" {
  project     = var.project_id
  name        = "hello-world-forwarding-rule"
  description = "Forwarding rule for the Hello World function"
  target      = google_compute_target_http_proxy.function_http_proxy.id
  port_range  = "80"
  load_balancing_scheme = "EXTERNAL"

  # Labels for resource organization
  labels = {
    environment = var.environment
    terraform   = "true"
    service     = "hello-world"
  }
}

# Optional: HTTPS Configuration
# To enable HTTPS, uncomment and configure:
# 1. SSL Certificate
# 2. HTTPS Proxy
# 3. HTTPS Forwarding Rule (port 443)