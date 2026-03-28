variable "app_name" {
  description = "Nombre de la aplicación"
  type        = string
}

variable "replica_count" {
  description = "Número de réplicas de contenedores"
  type        = number
  default     = 1
}

variable "memory_limit" {
  description = "Límite de memoria en MB"
  type        = number
  default     = 256
}

variable "external_ports" {
  description = "Puertos externos para los servicios"
  type        = map(number)
  default = {
    vote   = 8080
    result = 3000
  }
}

variable "enable_monitoring" {
  description = "Habilitar monitoreo"
  type        = bool
  default     = false
}

variable "backup_enabled" {
  description = "Habilitar backups"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "Región AWS (para LocalStack)"
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "Endpoint de LocalStack"
  type        = string
  default     = "http://localhost:4566"
}

variable "s3_bucket_suffix" {
  description = "Sufijo para el nombre del bucket S3"
  type        = string
  default     = "dev"
}

variable "database_password" {
  description = "Password para la base de datos"
  type        = string
  sensitive   = true
  default     = "default-password"
}
