# Desarrollo - Recursos mínimos con LocalStack
app_name = "roxs-voting-dev"
replica_count = 1
memory_limit = 256

external_ports = {
  vote   = 8080
  result = 3000
}

enable_monitoring = false
backup_enabled = false

# Configuración específica de LocalStack
aws_region = "us-east-1"
localstack_endpoint = "http://localhost:4566"
s3_bucket_suffix = "dev"
