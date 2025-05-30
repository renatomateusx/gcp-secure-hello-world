/**

 * Monitoring and Logging Configuration

 * 

 * This file contains Terraform code for setting up monitoring and logging

 * for the Hello World application. It creates:

 * 1. A custom dashboard for monitoring the Cloud Function and Load Balancer

 * 2. Alert policies for critical metrics

 * 3. Log-based metrics for tracking errors and usage patterns

 */

# Create a custom dashboard for the Hello World application

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

# Create an alert policy for high error rates

resource "google_monitoring_alert_policy" "high_error_rate" {

  project = var.project_id

  display_name = "High Error Rate Alert"

  combiner     = "OR"

  conditions {

    display_name = "Error rate > 5%"

    condition_threshold {

      filter     = "resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${var.load_balancer_name}\" AND metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND metric.labels.response_code_class=\"500\""

      duration   = "60s"

      comparison = "COMPARISON_GT"

      threshold_value = 0.05

      aggregations {

        alignment_period   = "60s"

        per_series_aligner = "ALIGN_RATE"

      }

    }

  }

  notification_channels = [

    google_monitoring_notification_channel.email.name

  ]

  documentation {

    content   = "The error rate for the Hello World application has exceeded 5% for more than 1 minute."

    mime_type = "text/markdown"

  }

}

# Create a notification channel for alerts

resource "google_monitoring_notification_channel" "email" {

  project      = var.project_id
  display_name = "Email Notification Channel"

  type         = "email"

  labels = {

    email_address = "alerts@example.com"

  }

}

# Create a log-based metric for tracking 405 Method Not Allowed responses

resource "google_logging_metric" "method_not_allowed" {

  project     = var.project_id

  name        = "method_not_allowed_count"

  description = "Count of 405 Method Not Allowed responses"

  filter      = "resource.type=\"http_load_balancer\" AND resource.labels.url_map_name=\"${var.load_balancer_name}\" AND httpRequest.status=405"

  metric_descriptor {

    metric_kind = "DELTA"

    value_type  = "INT64"

    labels {

      key         = "method"

      value_type  = "STRING"

      description = "HTTP method that was not allowed"

    }

  }

  label_extractors = {

    "method" = "EXTRACT(httpRequest.requestMethod)"

  }

}
