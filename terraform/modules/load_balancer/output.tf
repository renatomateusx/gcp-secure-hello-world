output "load_balancer_ip" {

  description = "The IP address of the global forwarding rule (Load Balancer)"

  value       = google_compute_global_forwarding_rule.function_forwarding_rule.ip_address

}

output "load_balancer_url" {

  description = "The URL to access the Load Balancer (HTTP)"

  value       = "http://${google_compute_global_forwarding_rule.function_forwarding_rule.ip_address}"

}

output "backend_service_name" {

  description = "The name of the backend service"

  value       = google_compute_backend_service.function_backend.name

}
