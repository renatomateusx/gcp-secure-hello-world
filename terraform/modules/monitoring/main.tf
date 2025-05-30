/**
 * Monitoring and Logging Configuration
 * 
 * This file contains Terraform code for setting up monitoring and logging
 * for the Hello World application. It creates:
 * 1. A custom dashboard for monitoring the Cloud Function and Load Balancer
 * 2. Alert policies for critical metrics
 * 3. Log-based metrics for tracking errors and usage patterns
 * 
 * The module sets up:
 * - Custom monitoring dashboard
 * - Alert policies
 * - Notification channels
 * - Log-based metrics
 */

# Custom Dashboard
# Creates a comprehensive dashboard with multiple widgets:
# - Function execution metrics
# - Load balancer performance
# - Error rates
# - Latency measurements
resource "google_monitoring_dashboard" "hello_world_dashboard" {
  project = var.project_id

  dashboard_json = <<EOF
{
  "displayName": "Hello World Application Dashboard",
  "gridLayout": {
    "widgets": [
      {
        "title": "Cloud Function Executions",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_function\" AND resource.labels.function_name=\"${var.function_name}\" AND metric.type=\"cloudfunctions.googleapis.com/function/execution_count\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "LINE"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "title": "Cloud Function Execution Times",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"cloud_function\" AND resource.labels.function_name=\"${var.function_name}\" AND metric.type=\"cloudfunctions.googleapis.com/function/execution_times\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_PERCENTILE_99"
                  }
                }
              },
              "plotType": "LINE"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "title": "Load Balancer Requests",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${var.load_balancer_name}\" AND metric.type=\"loadbalancing.googleapis.com/https/request_count\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "LINE"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "title": "Load Balancer Latency",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${var.load_balancer_name}\" AND metric.type=\"loadbalancing.googleapis.com/https/total_latencies\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_PERCENTILE_95"
                  }
                }
              },
              "plotType": "LINE"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "title": "Error Rate",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${var.load_balancer_name}\" AND metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND metric.labels.response_code_class=\"500\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE"
                  }
                }
              },
              "plotType": "LINE"
            }
          ],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      }
    ]
  }
}
EOF
}

# High Error Rate Alert
# Creates an alert policy that triggers when error rate exceeds threshold
# Monitors 500-level errors from the load balancer
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "High Error Rate Alert"
  combiner     = "OR"
  conditions {
    display_name = "Error rate is high"
    condition_threshold {
      filter     = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND resource.type=\"https_lb_rule\" AND metric.labels.response_code_class=\"500\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 5
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.name]
}

# Email Notification Channel
# Sets up email notifications for alerts
# Can be extended to include other notification methods
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Notifications"
  type         = "email"
  labels = {
    email_address = "your-email@example.com"
  }
}

# Method Not Allowed Metric
# Creates a log-based metric to track HTTP 405 errors
# Useful for monitoring unauthorized access attempts
resource "google_logging_metric" "method_not_allowed" {
  name        = "method_not_allowed"
  description = "Count of HTTP 405 Method Not Allowed responses"
  filter      = "resource.type=\"cloud_function\" AND resource.labels.function_name=\"${var.function_name}\" AND textPayload:\"405 Method Not Allowed\""
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}
