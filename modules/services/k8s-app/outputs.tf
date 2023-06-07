locals {
  status = kubernetes_service.app.status
}

output "service_endpoint" {
  value = try(
    "https://${local.status[0]["load_balancer"][0]["ingress"][0]["hostname"]}",
    "(error parsing hostnae from status)"
  )
  description = "The K8S Service endpoint"
}