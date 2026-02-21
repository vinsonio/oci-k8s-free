resource "helm_release" "traefik" {
  count            = var.install_ingress_controller ? 1 : 0
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true
  version          = "34.4.1" # Use a stable chart version

  # Configure Traefik as a NodePort service listening on specific backend ports
  values = [
    <<-EOF
    service:
      type: NodePort
    ports:
      web:
        port: 8000
        expose: {"nodePort": ${var.backend_port}}
        exposedPort: 80
      websecure:
        port: 8443
        expose: {"nodePort": ${var.backend_port_https}}
        exposedPort: 443
    EOF
  ]
}
