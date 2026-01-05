# Accommodation Service Helm Chart

Helm chart for deploying the Trubanb Accommodation Service microservice.

## Overview

This chart deploys the accommodation-service application with:
- PostgreSQL database connection (dedicated database: `accommodationdb`)
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
helm install accommodation-service . \
  --set database.host=my-postgresql \
  --set database.existingSecret=my-postgresql-secret \
  --set image.tag=v1.0.0
```

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/tehnotrube/accommodation-service` |
| `image.tag` | Image tag | `v1.0.0` |
| `database.host` | PostgreSQL host (auto-generated if empty) | `""` |
| `database.port` | PostgreSQL port | `5432` |
| `database.name` | Database name | `accommodationdb` |
| `database.existingSecret` | Secret containing DB credentials | `""` |
| `ingress.enabled` | Enable ingress | `false` |

### Database Configuration

The chart expects PostgreSQL credentials in a Kubernetes secret with keys:
- `username` - Database username
- `password` - Database password

If `database.existingSecret` is not provided, it defaults to `{{ .Release.Name }}-accommodation-postgresql`

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
extraEnv:
  - name: STORAGE_BUCKET
    value: "trubanb-accommodation-images-prod"
  - name: STORAGE_REGION
    value: "us-east-1"
```

## Database Schema

The accommodation-service requires the following database:
- Database name: `accommodationdb` (configurable)
- Expected schema: Accommodation listings, properties, amenities, availability

Migrations should be handled by the application on startup.

## API Endpoints

The service exposes:
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness check endpoint
- `POST /api/accommodations` - Create accommodation
- `GET /api/accommodations/:id` - Get accommodation details
- `GET /api/accommodations` - Search/list accommodations
- `PUT /api/accommodations/:id` - Update accommodation
- `DELETE /api/accommodations/:id` - Delete accommodation
- `GET /api/accommodations/:id/availability` - Check availability

(Actual endpoints depend on your application implementation)

## Integration with Other Services

### Reservation Service
The accommodation-service integrates with reservation-service for:
- Availability checking
- Booking confirmations
- Calendar management

### Rating Service
Accommodations can be rated by users through the rating-service integration.

## Troubleshooting

### Pod not starting

Check database connection:
```bash
kubectl logs -l app.kubernetes.io/name=accommodation-service
kubectl describe pod -l app.kubernetes.io/name=accommodation-service
```

### Database connection issues

Verify secret exists:
```bash
kubectl get secret <release-name>-accommodation-postgresql
```

Check database host resolution:
```bash
kubectl exec -it <pod-name> -- nslookup <database-host>
```

### Image storage issues

If using external image storage (S3, GCS, etc.), ensure proper credentials are configured via `extraEnv`:

```yaml
extraEnv:
  - name: STORAGE_BUCKET
    value: "accommodation-images"
  - name: STORAGE_REGION
    value: "us-east-1"
```

## License

Copyright © 2025 Trubanb
