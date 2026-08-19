resource "docker_network" "app_network" {
  name   = "gestion-usuarios-network"
  driver = "bridge"
}

resource "docker_volume" "mysql_data" {
  name = "gestion-usuarios-mysql-data"
}

resource "docker_container" "mysql" {
  name  = "mysql-terraform"
  image = "mysql:8.4"

  restart = "unless-stopped"

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}"
  ]

  ports {
    internal = 3306
    external = 3308
  }

  volumes {
    volume_name    = docker_volume.mysql_data.name
    container_path = "/var/lib/mysql"
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  remove_volumes = false
}

resource "docker_image" "backend" {
  name = "gestion-usuarios-devops-backend:latest"

  build {
    context    = "${path.module}/../backend"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "backend" {
  name  = "backend-terraform"
  image = docker_image.backend.image_id

  restart        = "unless-stopped"
  remove_volumes = false

  env = [
    "PORT=3000",
    "DB_HOST=mysql-terraform",
    "DB_PORT=3306",
    "DB_USER=${var.mysql_user}",
    "DB_PASSWORD=${var.mysql_password}",
    "DB_DATABASE=${var.mysql_database}",
    "JWT_SECRET=${var.jwt_secret}"
  ]

  ports {
    internal = 3000
    external = 3001
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  depends_on = [
    docker_container.mysql
  ]
}