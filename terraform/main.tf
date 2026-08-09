resource "docker_network" "app_network" {
  name   = "gestion-usuarios-network"
  driver = "bridge"
}

resource "docker_volume" "mysql_data" {
  name = "gestion-usuarios-mysql-data"
}