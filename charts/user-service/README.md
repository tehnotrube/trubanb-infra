# User Service Helm Chart

Helm chart for deploying the Trubanb User Service microservice.

## Overview

This chart deploys the user-service application with:
- PostgreSQL database connection
- Kong Ingress for API Gateway routing
- Health checks (liveness & readiness probes)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PostgreSQL database (deployed via umbrella chart)
- Kong Ingress Controller

## Installation

This chart is typically installed as part of the umbrella chart, but can be installed standalone:

```bash
helm install user-service . \
  --set database.host=my-postgresql \
  --set database.existingSecret=my-postgresql-secret \
  --set image.tag=v1.0.0
```

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/tehnotrube/user-service` |
| `image.tag` | Image tag | `v1.0.0` |
| `database.host` | PostgreSQL host (auto-generated if empty) | `""` |
| `database.port` | PostgreSQL port | `5432` |
| `database.name` | Database name | `userdb` |
| `database.existingSecret` | Secret containing DB credentials | `""` |
| `ingress.enabled` | Enable ingress | `false` |

### Database Configuration

The chart expects PostgreSQL credentials in a Kubernetes secret with keys:
- `username` - Database username
- `password` - Database password

If `database.existingSecret` is not provided, it defaults to `{{ .Release.Name }}-user-postgresql`

## Health Checks

### Liveness Probe
- Path: `/health`
- Initial delay: 30s
- Period: 10s

### Readiness Probe
- Path: `/ready`
- Initial delay: 10s
- Period: 5s

## Examples

### Development Environment

```yaml
replicaCount: 1
image:
  tag: dev
resources:
  limits:
    cpu: 200m
    memory: 256Mi
```

### Production Environment

```yaml
replicaCount: 3
image:
  tag: v1.0.0
  pullPolicy: Always
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

## Database Schema

The user-service requires the following database:
- Database name: `userdb` (configurable)
- Expected schema: User tables and relations

Migrations should be handled by the application on startup.

## API Endpoints

The service exposes:
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness check endpoint
- `POST /api/users` - Create user
- `GET /api/users/:id` - Get user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

(Actual endpoints depend on your application implementation)

## Troubleshooting

### Pod not starting

Check database connection:
```bash
kubectl logs -l app.kubernetes.io/name=user-service
kubectl describe pod -l app.kubernetes.io/name=user-service
```

### Database connection issues

Verify secret exists:
```bash
kubectl get secret <release-name>-user-postgresql
```

Check database host resolution:
```bash
kubectl exec -it <pod-name> -- nslookup <database-host>
```

## License

Copyright © 2025 Trubanb
