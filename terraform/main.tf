resource "docker_network" "app_network" {
  name   = "gestion-usuarios-network"
  driver = "bridge"
}