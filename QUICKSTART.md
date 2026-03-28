# 🚀 Quick Start - Día 27 LocalStack + Terraform

## 📋 Prerequisitos
```bash
# Instalar awslocal (wrapper para LocalStack)
pip install awscli-local
```

## ⚡ Setup en 3 Pasos

### 1️⃣ Iniciar LocalStack
```bash
cd semana-4/dia-27
docker-compose -f docker-compose.localstack.yml up -d
chmod +x scripts/*.sh
./scripts/setup-localstack.sh
```

### 2️⃣ Inicializar Terraform
```bash
export AWS_ENDPOINT_URL=http://localhost:4566
terraform init \
  -backend-config="endpoint=http://localhost:4566" \
  -backend-config="access_key=test" \
  -backend-config="secret_key=test"
```

### 3️⃣ Desplegar
```bash
# Dev
terraform workspace new dev
terraform apply -var-file="environments/dev.tfvars"

# Staging
terraform workspace new staging
terraform apply -var-file="environments/staging.tfvars"

# Prod
terraform workspace new prod
terraform apply -var-file="environments/prod.tfvars"
```

## 🧪 Verificar

```bash
# Ver estado en S3
awslocal s3 ls s3://terraform-state-roxs/

# Ver contenedores
docker ps --filter label=managed-by=terraform

# Ver outputs
terraform output
```

## 🧹 Limpiar

```bash
# Destruir ambiente
terraform workspace select dev
terraform destroy -var-file="environments/dev.tfvars"

# Detener LocalStack
docker-compose -f docker-compose.localstack.yml down
```

## 📊 Ambientes

| Ambiente | Puerto | Réplicas | Memoria |
|----------|--------|----------|---------|
| dev | 8080 | 1 | 256 MB |
| staging | 8081 | 2 | 512 MB |
| prod | 80 | 3 | 1024 MB |

## ❓ Troubleshooting

**LocalStack no responde:**
```bash
docker logs terraform-localstack
./scripts/wait-for-localstack.sh
```

**Backend error:**
```bash
rm -rf .terraform
terraform init -backend-config="endpoint=http://localhost:4566" \
  -backend-config="access_key=test" -backend-config="secret_key=test"
```

Ver [README.md](README.md) para documentación completa.
