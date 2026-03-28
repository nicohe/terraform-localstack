# Staging - Configuración intermedia con LocalStack
app_name = "roxs-voting-staging"
replica_count = 2
memory_limit = 512

external_ports = {
  vote   = 8081
  result = 3001
}

enable_monitoring = true
backup_enabled = true

# Configuración específica de LocalStack
aws_region = "us-east-1"
localstack_endpoint = "http://localhost:4566"
s3_bucket_suffix = "staging"
