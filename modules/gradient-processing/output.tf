output "traefik_service" {
  value = data.kubernetes_service.traefik
}

output "gradient_processing_values" {
  value = helm_release.gradient_processing.values
}
