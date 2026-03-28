# Imagen de Docker para vote service
resource "docker_image" "vote" {
  name         = "voting/vote:latest"
  keep_locally = false
}

# Red para los servicios
resource "docker_network" "app_network" {
  name = "${var.app_name}-network"
}

# Contenedores para vote service
resource "docker_container" "vote" {
  count = var.replica_count

  name  = "${var.app_name}-vote-${count.index + 1}"
  image = docker_image.vote.image_id

  # Puerto solo en el primer contenedor
  dynamic "ports" {
    for_each = count.index == 0 ? [1] : []
    content {
      internal = 80
      external = var.external_ports["vote"]
    }
  }

  # Variables de entorno
  env = [
    "ENVIRONMENT=${terraform.workspace}",
    "REPLICA_ID=${count.index + 1}",
    "TOTAL_REPLICAS=${var.replica_count}",
    "LOCALSTACK_ENDPOINT=${var.localstack_endpoint}"
  ]

  # Límites de recursos
  memory = var.memory_limit

  # Conectar a la red
  networks_advanced {
    name = docker_network.app_network.name
  }

  # Labels para identificar
  labels {
    label = "environment"
    value = terraform.workspace
  }

  labels {
    label = "managed-by"
    value = "terraform"
  }

  labels {
    label = "app"
    value = "roxs-voting"
  }
}

# Archivo de configuración local
resource "local_file" "deployment_info" {
  filename = "${path.module}/deployment-${terraform.workspace}.json"
  content = jsonencode({
    environment       = terraform.workspace
    app_name          = var.app_name
    replica_count     = var.replica_count
    memory_limit      = var.memory_limit
    external_ports    = var.external_ports
    enable_monitoring = var.enable_monitoring
    backup_enabled    = var.backup_enabled
    deployed_at       = timestamp()
  })
}
