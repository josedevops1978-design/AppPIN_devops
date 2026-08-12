# =====================================================================
# Todas las variables necesarias para este modulo viven en este unico
# archivo. Copia terraform.tfvars.example a terraform.tfvars y completa
# los valores reales (ese archivo esta en .gitignore, nunca se sube).
# =====================================================================

# --- Conexion SSH a la VM de VirtualBox ya creada ---

variable "vm_ssh_host" {
  description = "IP o hostname de la VM de VirtualBox (ej: 192.168.56.10)"
  type        = string
}

variable "vm_ssh_port" {
  description = "Puerto SSH de la VM"
  type        = number
  default     = 22
}

variable "vm_ssh_user" {
  description = "Usuario SSH de la VM. Debe tener sudo sin password (NOPASSWD)"
  type        = string
}

variable "vm_ssh_password" {
  description = "Password SSH de la VM"
  type        = string
  sensitive   = true
}

# --- Registro del runner en GitHub Actions ---

variable "github_owner" {
  description = "Owner (usuario u organizacion) del repositorio en GitHub"
  type        = string
}

variable "github_repo" {
  description = "Nombre del repositorio en GitHub donde se registra el runner"
  type        = string
}

variable "github_pat" {
  description = "Personal Access Token de GitHub usado para generar el registration token del runner en cada apply. Necesita permiso 'Administration: Read and write' (fine-grained) o scope 'repo' (classic) sobre el repositorio."
  type        = string
  sensitive   = true
}

variable "runner_name" {
  description = "Nombre con el que el runner aparece en GitHub (Settings > Actions > Runners)"
  type        = string
  default     = "virtualbox-runner-01"
}

variable "runner_labels" {
  description = "Labels separados por coma asignados al runner"
  type        = string
  default     = "self-hosted,linux,x64,virtualbox"
}

variable "runner_work_dir" {
  description = "Carpeta de trabajo del runner dentro de la VM"
  type        = string
  default     = "_work"
}

variable "runner_version" {
  description = "Version del paquete actions-runner a instalar (ver https://github.com/actions/runner/releases)"
  type        = string
  default     = "2.321.0"
}
