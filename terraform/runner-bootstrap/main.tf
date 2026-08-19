locals {
  bootstrap_script_path = "${path.module}/files/bootstrap-runner.sh"
  deploy_dir            = "/home/${var.vm_ssh_user}/${var.app_deploy_dir}"

  app_env_content = <<-EOT
    MYSQL_ROOT_PASSWORD=${var.mysql_root_password}
    MYSQL_DATABASE=${var.mysql_database}
    MYSQL_USER=${var.mysql_user}
    MYSQL_PASSWORD=${var.mysql_password}
    PORT=3000
    DB_HOST=mysql
    DB_PORT=3306
    DB_USER=${var.mysql_user}
    DB_PASSWORD=${var.mysql_password}
    DB_DATABASE=${var.mysql_database}
    JWT_SECRET=${var.jwt_secret}
  EOT
}

resource "null_resource" "runner_bootstrap" {
  triggers = {
    script_sha1 = filesha1(local.bootstrap_script_path)
    runner_name = var.runner_name
    vm_host     = var.vm_ssh_host
    env_sha1    = sha1(local.app_env_content)
  }

  connection {
    type     = "ssh"
    host     = var.vm_ssh_host
    port     = var.vm_ssh_port
    user     = var.vm_ssh_user
    password = var.vm_ssh_password
    timeout  = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.deploy_dir}",
    ]
  }

  provisioner "file" {
    content     = local.app_env_content
    destination = "${local.deploy_dir}/.env"
  }

  provisioner "file" {
    source      = local.bootstrap_script_path
    destination = "/tmp/bootstrap-runner.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "chmod +x /tmp/bootstrap-runner.sh",
      "sudo -n GITHUB_PAT='${var.github_pat}' /tmp/bootstrap-runner.sh '${var.github_owner}' '${var.github_repo}' '${var.runner_name}' '${var.runner_labels}' '${var.runner_work_dir}' '${var.runner_version}'",
      "rm -f /tmp/bootstrap-runner.sh",
    ]
  }
}
