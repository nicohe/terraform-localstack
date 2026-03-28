output "app_info" {
  description = "Información de la aplicación desplegada"
  value = {
    environment       = terraform.workspace
    app_name          = var.app_name
    app_url           = "http://localhost:${var.external_ports["vote"]}"
    replica_count     = var.replica_count
    memory_limit      = "${var.memory_limit}MB"
    container_names   = docker_container.vote[*].name
    network_name      = docker_network.app_network.name
    monitoring        = var.enable_monitoring ? "Enabled" : "Disabled"
    backup            = var.backup_enabled ? "Enabled" : "Disabled"
    localstack        = var.localstack_endpoint
  }
}

output "quick_commands" {
  description = "Comandos útiles para este ambiente"
  value = {
    view_logs       = "docker logs ${var.app_name}-vote-1"
    connect         = "docker exec -it ${var.app_name}-vote-1 /bin/sh"
    test_app        = "curl http://localhost${var.external_ports["vote"]}"
    list_containers = "docker ps --filter label=environment=${terraform.workspace}"
    s3_check        = "awslocal s3 ls s3://terraform-state-roxs/"
  }
}

output "environment_info" {
  description = "Información del workspace actual"
  value = {
    workspace      = terraform.workspace
    is_dev         = terraform.workspace == "dev"
    is_staging     = terraform.workspace == "staging"
    is_prod        = terraform.workspace == "prod"
    s3_bucket      = "terraform-state-roxs"
    s3_key         = "workspaces/${terraform.workspace}/terraform.tfstate"
  }
}
