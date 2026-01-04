# Trubanb Umbrella Chart

Complete Helm chart for deploying the entire Trubanb microservices platform.

## Overview

This umbrella chart deploys:
- **Kong API Gateway** - API Gateway and Ingress Controller
- **4 Microservices**:
  - user-service (PostgreSQL)
  - accommodation-service (PostgreSQL)
  - reservation-service (PostgreSQL)
  - rating-service (MongoDB)
- **3 PostgreSQL Databases** (separate instances)
- **1 MongoDB Database**

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8+
- kubectl configured
- Storage provisioner for persistent volumes

## Quick Start

### 1. Update Dependencies

First, download all external chart dependencies:

```bash
cd umbrella-chart
helm dependency update
```

This downloads:
- Kong chart from Kong repository
- PostgreSQL charts from Bitnami
- MongoDB chart from Bitnami
- Your local microservice charts

### 2. Install (Development)

```bash
helm install trubanb . -f ../environments/values-dev.yaml
```

### 3. Check Installation

```bash
# Check all pods
kubectl get pods

# Check services
kubectl get svc

# Check ingress
kubectl get ingress
```

## Installation Options

### Development Environment

```bash
helm install trubanb . \
  -f ../environments/values-dev.yaml \
  --create-namespace \
  --namespace trubanb-dev
```

**Features:**
- NodePort for Kong (local access)
- Single replica per service
- Small resource limits
- Simple passwords (not for production!)

**Access:**
```bash
# Get Kong proxy port
kubectl get svc trubanb-kong-proxy -n trubanb-dev

# Access APIs
curl http://localhost:<NODEPORT>/api/users
curl http://localhost:<NODEPORT>/api/accommodations
curl http://localhost:<NODEPORT>/api/reservations
curl http://localhost:<NODEPORT>/api/ratings
```

### Production Environment

⚠️ **IMPORTANT:** Production requires external secret management!

```bash
# Create secrets first (example using kubectl)
kubectl create secret generic user-db-secret \
  --from-literal=password='<secure-password>' \
  -n trubanb-prod

kubectl create secret generic accommodation-db-secret \
  --from-literal=password='<secure-password>' \
  -n trubanb-prod

kubectl create secret generic reservation-db-secret \
  --from-literal=password='<secure-password>' \
  -n trubanb-prod

kubectl create secret generic mongodb-secret \
  --from-literal=mongodb-root-password='<secure-password>' \
  --from-literal=mongodb-password='<secure-password>' \
  -n trubanb-prod

# Install chart
helm install trubanb . \
  -f ../environments/values-prod.yaml \
  --create-namespace \
  --namespace trubanb-prod
```

**Features:**
- LoadBalancer for Kong
- 3 replicas per service
- Autoscaling enabled
- Pod Disruption Budgets
- Production resource limits
- SSL/TLS configured

## Configuration

### Database Passwords

**Development:**
Simple passwords are set in `values-dev.yaml` (for convenience only!)

**Production:**
NEVER commit passwords! Use one of:

1. **Kubernetes Secrets** (manual):
```bash
kubectl create secret generic user-db-secret \
  --from-literal=password='your-secure-password'
```

2. **Sealed Secrets**:
```bash
# Install sealed-secrets controller first
kubeseal < secret.yaml > sealed-secret.yaml
kubectl apply -f sealed-secret.yaml
```

3. **External Secrets Operator**:
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: user-db-secret
spec:
  secretStoreRef:
    name: aws-secretsmanager
  target:
    name: user-db-secret
  data:
  - secretKey: password
    remoteRef:
      key: prod/trubanb/user-db-password
```

4. **HashiCorp Vault**, **AWS Secrets Manager**, **Azure Key Vault**, etc.

### Customizing Services

Override any service configuration:

```bash
helm install trubanb . \
  -f ../environments/values-dev.yaml \
  --set user-service.replicaCount=3 \
  --set user-service.image.tag=v1.2.0
```

### Disabling Services

Disable specific services:

```bash
helm install trubanb . \
  -f ../environments/values-dev.yaml \
  --set rating-service.enabled=false \
  --set mongodb.enabled=false
```

## Upgrading

### Update Chart Dependencies

```bash
helm dependency update
```

### Upgrade Release

```bash
helm upgrade trubanb . \
  -f ../environments/values-prod.yaml
```

### Upgrade Specific Service

```bash
helm upgrade trubanb . \
  --reuse-values \
  --set user-service.image.tag=v1.2.0
```

## Uninstalling

```bash
# Uninstall release
helm uninstall trubanb -n trubanb-dev

# Delete namespace (optional)
kubectl delete namespace trubanb-dev
```

⚠️ **Note:** PersistentVolumeClaims are NOT deleted automatically. Delete manually if needed:

```bash
kubectl delete pvc --all -n trubanb-dev
```

## Monitoring

### Check Service Health

```bash
# User service
kubectl exec -it <user-service-pod> -- curl localhost:8080/health

# Accommodation service
kubectl exec -it <accommodation-service-pod> -- curl localhost:8080/health

# Reservation service
kubectl exec -it <reservation-service-pod> -- curl localhost:8080/health

# Rating service
kubectl exec -it <rating-service-pod> -- curl localhost:8080/health
```

### Database Connections

```bash
# PostgreSQL (user-service)
kubectl exec -it trubanb-postgresql-user-0 -- psql -U userservice -d userdb

# PostgreSQL (accommodation-service)
kubectl exec -it trubanb-postgresql-accommodation-0 -- psql -U accommodationservice -d accommodationdb

# PostgreSQL (reservation-service)
kubectl exec -it trubanb-postgresql-reservation-0 -- psql -U reservationservice -d reservationdb

# MongoDB
kubectl exec -it trubanb-mongodb-0 -- mongosh -u ratingservice -p <password> ratingsdb
```

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Kong Gateway                              │
│                   (API Gateway / Ingress)                         │
└────────┬──────────────┬──────────────┬──────────────┬────────────┘
         │              │              │              │
    ┌────▼─────┐  ┌────▼──────┐  ┌───▼──────┐  ┌───▼────────┐
    │  user-   │  │accommoda- │  │reserva-  │  │  rating-   │
    │ service  │  │   tion-   │  │  tion-   │  │  service   │
    │          │  │  service  │  │ service  │  │            │
    └────┬─────┘  └────┬──────┘  └───┬──────┘  └───┬────────┘
         │              │              │              │
    ┌────▼─────┐  ┌────▼──────┐  ┌───▼──────┐  ┌───▼────────┐
    │PostgreSQL│  │PostgreSQL │  │PostgreSQL│  │  MongoDB   │
    │ (userdb) │  │(accommoda-│  │(reserva- │  │(ratingsdb) │
    │          │  │  tiondb)  │  │  tiondb) │  │            │
    └──────────┘  └───────────┘  └──────────┘  └────────────┘
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Database Connection Issues

```bash
# Check secrets exist
kubectl get secrets

# Verify database pods are running
kubectl get pods | grep postgres
kubectl get pods | grep mongodb

# Check service endpoints
kubectl get endpoints
```

### Ingress Not Working

```bash
# Check Kong pods
kubectl get pods | grep kong

# Check ingress resources
kubectl get ingress

# Check Kong proxy service
kubectl get svc trubanb-kong-proxy
```

### Dependency Update Fails

```bash
# Clean chart cache
rm -rf charts/*.tgz Chart.lock

# Update again
helm dependency update
```

## Development Workflow

### Local Development

1. **Start local cluster** (minikube/kind/k3d)
```bash
minikube start
```

2. **Install dev environment**
```bash
helm install trubanb . -f ../environments/values-dev.yaml
```

3. **Port forward Kong**
```bash
kubectl port-forward svc/trubanb-kong-proxy 8000:80
```

4. **Access APIs**
```bash
curl http://localhost:8000/api/users
```

### Update Service Code

1. Build new image
2. Push to registry
3. Update image tag
```bash
helm upgrade trubanb . \
  --reuse-values \
  --set user-service.image.tag=v1.1.0
```

## Values Files

- `values.yaml` - Base configuration
- `../environments/values-dev.yaml` - Development overrides
- `../environments/values-prod.yaml` - Production overrides

## Chart Structure

```
umbrella-chart/
├── Chart.yaml           # Chart metadata and dependencies
├── values.yaml          # Default values
├── charts/              # Downloaded dependencies (generated)
│   ├── kong-2.38.0.tgz
│   ├── postgresql-18.2.0.tgz (x3 instances)
│   ├── mongodb-18.1.20.tgz
│   ├── user-service-0.1.0.tgz
│   ├── accommodation-service-0.1.0.tgz
│   ├── reservation-service-0.1.0.tgz
│   └── rating-service-0.1.0.tgz
└── Chart.lock           # Locked dependency versions
```

## Support

For issues or questions:
1. Check logs: `kubectl logs <pod-name>`
2. Check events: `kubectl get events`
3. Check service status: `kubectl get all`

## License

Copyright © 2025 Trubanb
