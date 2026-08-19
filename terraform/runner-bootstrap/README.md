# Runner Bootstrap

Prepara una VM de VirtualBox **ya existente** (se conecta por SSH con IP/usuario/password)
para correr el proyecto y la registra como self-hosted runner de GitHub Actions.

Instala: Docker Engine, plugin `docker compose` + binario clásico `docker-compose`, git, jq.
Luego descarga el agente `actions-runner`, lo configura contra el repo y lo deja corriendo
como servicio systemd.

También deja escrito en la VM, en `/home/<vm_ssh_user>/<app_deploy_dir>/.env` (por defecto
`~/pin-app-deploy/.env`), el archivo `.env` que necesita `docker-compose.yml` de la raíz del
repo (`MYSQL_*`, `DB_*`, `JWT_SECRET`). El job `deploy` del CI clona/actualiza el repo en esa
misma carpeta y corre `docker compose up` ahí, tomando esas variables automáticamente.

Este módulo se corre una sola vez, manualmente, desde la máquina que tiene acceso SSH a la VM
(y de nuevo cada vez que cambian las credenciales de la app o la config del runner).

## Requisitos

- La VM ya existe, tiene Ubuntu/Debian, y es alcanzable por SSH.
- El usuario SSH tiene sudo sin password (NOPASSWD) — estándar en la mayoría de imágenes cloud/Vagrant.
- Un Personal Access Token de GitHub con permiso `Administration: Read and write` (fine-grained)
  o scope `repo` (classic) sobre el repositorio, para poder generar el registration token del runner.

## Uso

```bash
cd terraform/runner-bootstrap
cp terraform.tfvars.example terraform.tfvars
# completar terraform.tfvars con los valores reales (IP, usuario, password, PAT, etc.)

terraform init
terraform apply
```

Volver a correr `terraform apply` es seguro (idempotente): si Docker o el runner ya están
instalados/registrados, el script los deja como están.

Después de aplicar, el runner aparece en GitHub en **Settings > Actions > Runners** del repo,
con las labels definidas en `runner_labels`. Para que un job del workflow lo use, su `runs-on`
debe incluir esas labels (por ejemplo `runs-on: [self-hosted, virtualbox]`).
