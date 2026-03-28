# Día 27 - CI/CD para Terraform con LocalStack

## 🎯 Objetivo

Implementar un proyecto Terraform con **LocalStack** como simulador de AWS, integrando backend S3 remoto para estado y gestión de múltiples ambientes (dev, staging, prod).

## 🤔 ¿Qué es LocalStack?

**LocalStack** es una plataforma que simula los servicios de AWS en tu máquina local, permitiendo desarrollar y probar aplicaciones cloud sin necesidad de conectarse a AWS real.

### Beneficios:
- 💰 **Sin costos**: No pagas por recursos AWS durante desarrollo
- 🚀 **Desarrollo rápido**: Testing instantáneo sin latencia de red
- 🔒 **Privacidad**: Datos sensibles nunca salen de tu máquina
- 🧪 **Testing seguro**: Experimenta sin riesgo de afectar producción

## 📁 Estructura del Proyecto

```
dia-27/
├── README.md                         # Esta guía
├── QUICKSTART.md                     # Guía rápida
├── docker-compose.localstack.yml     # LocalStack setup
├── backend.tf                        # Backend S3 con LocalStack
├── main.tf                          # Recursos Terraform
├── variables.tf                     # Variables del proyecto
├── outputs.tf                       # Outputs
├── .gitignore                       # Archivos a ignorar
├── scripts/
│   ├── setup-localstack.sh          # Script de configuración
│   └── wait-for-localstack.sh       # Script de espera
└── environments/
    ├── dev.tfvars                   # Variables desarrollo
    ├── staging.tfvars               # Variables staging
    └── prod.tfvars                  # Variables producción
```

## 🚀 Inicio Rápido

### Prerequisitos
- Docker Desktop instalado y corriendo
- Terraform instalado (>= 1.6.0)
- AWS CLI instalado
- awslocal instalado (`pip install awscli-local`)
- Git bash (Windows) o bash shell (macOS/Linux)

### 1. Iniciar LocalStack

```bash
# Iniciar LocalStack
docker-compose -f docker-compose.localstack.yml up -d

# Verificar que esté corriendo
curl http://localhost:4566/_localstack/health
```

### 2. Configurar LocalStack

```bash
# Dar permisos a los scripts
chmod +x scripts/*.sh

# Configurar LocalStack (crear bucket S3, etc)
export AWS_ENDPOINT_URL=http://localhost:4566
./scripts/setup-localstack.sh
```

### 3. Inicializar Terraform con Backend S3

```bash
# Inicializar con backend S3 de LocalStack
terraform init \
  -backend-config="endpoints.s3=http://localhost:4566" \
  -backend-config="access_key=test" \
  -backend-config="secret_key=test"
```

### 4. Desplegar a Desarrollo

```bash
# Crear workspace dev
terraform workspace new dev || terraform workspace select dev

# Aplicar configuración
export AWS_ENDPOINT_URL=http://localhost:4566
terraform apply -var-file="environments/dev.tfvars"
```

### 5. Verificar Despliegue

```bash
# Ver outputs
terraform output

# Ver estado en S3 LocalStack
awslocal s3 ls s3://terraform-state-roxs/

# Verificar contenedores
docker ps --filter label=environment=dev
```

## 📊 Archivos de Variables por Ambiente

### environments/dev.tfvars
```hcl
# Desarrollo - Recursos mínimos
app_name = "roxs-voting-dev"
replica_count = 1
memory_limit = 256
external_ports = {
  vote   = 8080
  result = 3000
}
localstack_endpoint = "http://localhost:4566"
```

### environments/staging.tfvars
```hcl
# Staging - Configuración intermedia
app_name = "roxs-voting-staging"
replica_count = 2
memory_limit = 512
external_ports = {
  vote   = 8081
  result = 3001
}
localstack_endpoint = "http://localhost:4566"
```

### environments/prod.tfvars
```hcl
# Producción - Máximos recursos
app_name = "roxs-voting-prod"
replica_count = 3
memory_limit = 1024
external_ports = {
  vote   = 80
  result = 3000
}
localstack_endpoint = "http://localhost:4566"
```

## 🔄 Workflow Completo

### 1. Desarrollo Local
```bash
# Iniciar LocalStack
docker-compose -f docker-compose.localstack.yml up -d

# Configurar
./scripts/setup-localstack.sh

# Desplegar a dev
terraform workspace new dev
export AWS_ENDPOINT_URL=http://localhost:4566
terraform apply -var-file="environments/dev.tfvars"

# Probar
curl http://localhost:8080
```

### 2. Staging
```bash
# Cambiar a staging
terraform workspace new staging || terraform workspace select staging

# Aplicar
export AWS_ENDPOINT_URL=http://localhost:4566
terraform apply -var-file="environments/staging.tfvars"

# Verificar
curl http://localhost:8081
```

### 3. Producción
```bash
# Cambiar a prod
terraform workspace new prod || terraform workspace select prod

# Aplicar con review
export AWS_ENDPOINT_URL=http://localhost:4566
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"

# Verificar
curl http://localhost:80
```

## 🛠️ Comandos Útiles

### LocalStack
```bash
# Ver salud de LocalStack
curl http://localhost:4566/_localstack/health

# Ver servicios disponibles
curl http://localhost:4566/_localstack/info

# Listar buckets S3
awslocal s3 ls

# Ver contenido del bucket de estado
awslocal s3 ls s3://terraform-state-roxs/ --recursive

# Ver logs de LocalStack
docker logs terraform-localstack

# Reiniciar LocalStack
docker-compose -f docker-compose.localstack.yml restart
```

### Terraform
```bash
# Ver workspace actual
terraform workspace show

# Listar workspaces
terraform workspace list

# Ver estado
terraform state list

# Ver outputs
terraform output

# Verificar formato
terraform fmt

# Validar
terraform validate
```

### Docker
```bash
# Ver contenedores activos
docker ps --filter label=managed-by=terraform

# Ver por ambiente
docker ps --filter label=environment=dev

# Ver logs
docker logs roxs-voting-dev-vote-1

# Conectarse a contenedor
docker exec -it roxs-voting-dev-vote-1 /bin/sh
```

## 🧹 Limpieza

### Destruir un Ambiente
```bash
# Seleccionar ambiente
terraform workspace select dev

# Destruir
export AWS_ENDPOINT_URL=http://localhost:4566
terraform destroy -var-file="environments/dev.tfvars"
```

### Destruir Todos los Ambientes
```bash
for env in dev staging prod; do
  terraform workspace select $env
  export AWS_ENDPOINT_URL=http://localhost:4566
  terraform destroy -var-file="environments/$env.tfvars" -auto-approve
done

terraform workspace select default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod
```

### Detener LocalStack
```bash
docker-compose -f docker-compose.localstack.yml down

# Limpiar volúmenes también
docker-compose -f docker-compose.localstack.yml down -v
```

## 🚨 Troubleshooting

### LocalStack no está listo
```bash
# Solución: Esperar más tiempo
./scripts/wait-for-localstack.sh

# Ver logs
docker logs terraform-localstack
```

### Bucket S3 no encontrado
```bash
# Recrear bucket
awslocal s3 mb s3://terraform-state-roxs
```

### Error de backend init
```bash
# Reinicializar con configuración correcta
rm -rf .terraform
terraform init \
  -backend-config="endpoints.s3=http://localhost:4566" \
  -backend-config="access_key=test" \
  -backend-config="secret_key=test"
```

### Puerto ya en uso
```bash
# Verificar qué está usando el puerto
lsof -i :4566

# Detener contenedores conflictivos
docker stop $(docker ps -q --filter "publish=4566")
```

## 💡 Mejores Prácticas

✅ **Hacer:**
- Usar LocalStack para desarrollo y testing
- Configurar persistencia de datos
- Usar health checks before operations  
- Separar configuración por ambiente en .tfvars
- Versionar bucket S3 para estado

❌ **Evitar:**
- Usar LocalStack en producción real
- Hardcodear credenciales
- Compartir estado sin locking
- Modificar el estado manualmente

## 📚 Conceptos Clave Aprendidos

- ✅ LocalStack como simulador de AWS
- ✅ Backend S3 remoto para estado de Terraform
- ✅ Workspaces de Terraform para múltiples ambientes
- ✅ Variables por ambiente con .tfvars
- ✅ Health checks y wait scripts
- ✅ Gestión de credenciales con LocalStack

## 🔗 Referencias

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [Terraform S3 Backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
- [LocalStack with Terraform](https://docs.localstack.cloud/user-guide/integrations/terraform/)
- [Día 27 - Curriculum completo](https://90daysdevops.295devops.com/semana-04/dia27)

---

**¡Excelente trabajo automatizando con LocalStack!** 🚀🎉
