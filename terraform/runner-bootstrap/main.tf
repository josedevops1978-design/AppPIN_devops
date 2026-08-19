locals {
  bootstrap_script_path = "${path.module}/files/bootstrap-runner.sh"
}

resource "null_resource" "runner_bootstrap" {
  triggers = {
    script_sha1 = filesha1(local.bootstrap_script_path)
    runner_name = var.runner_name
    vm_host     = var.vm_ssh_host
  }

  connection {
    type     = "ssh"
    host     = var.vm_ssh_host
    port     = var.vm_ssh_port
    user     = var.vm_ssh_user
    password = var.vm_ssh_password
    timeout  = "2m"
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
