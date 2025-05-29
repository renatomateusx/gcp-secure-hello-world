output "dashboard_name" {

  description = "The name of the created monitoring dashboard"

  value       = google_monitoring_dashboard.hello_world_dashboard.id

}

output "alert_policy_name" {

  description = "The name of the created alert policy"

  value       = google_monitoring_alert_policy.high_error_rate.display_name

}

output "notification_channel" {

  description = "The notification channel for alerts"

  value       = google_monitoring_notification_channel.email.display_name

}
