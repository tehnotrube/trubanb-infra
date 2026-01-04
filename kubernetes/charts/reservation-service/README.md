# Reservation Service Helm Chart

Helm chart for deploying the Trubanb Reservation Service microservice.

## Overview

This chart deploys the reservation-service application with:
- PostgreSQL database connection (dedicated database: `reservationdb`)
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
helm install reservation-service . \
  --set database.host=my-postgresql \
  --set database.existingSecret=my-postgresql-secret \
  --set image.tag=v1.0.0
```

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/tehnotrube/reservation-service` |
| `image.tag` | Image tag | `v1.0.0` |
| `database.host` | PostgreSQL host (auto-generated if empty) | `""` |
| `database.port` | PostgreSQL port | `5432` |
| `database.name` | Database name | `reservationdb` |
| `database.existingSecret` | Secret containing DB credentials | `""` |
| `ingress.enabled` | Enable ingress | `false` |

### Database Configuration

The chart expects PostgreSQL credentials in a Kubernetes secret with keys:
- `username` - Database username
- `password` - Database password

If `database.existingSecret` is not provided, it defaults to `{{ .Release.Name }}-reservation-postgresql`

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
  - name: PAYMENT_SERVICE_URL
    value: "http://payment-service:8080"
  - name: NOTIFICATION_SERVICE_URL
    value: "http://notification-service:8080"
```

## Database Schema

The reservation-service requires the following database:
- Database name: `reservationdb` (configurable)
- Expected schema: Reservations, bookings, payment records, availability calendar

Migrations should be handled by the application on startup.

## API Endpoints

The service exposes:
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness check endpoint
- `POST /api/reservations` - Create new reservation
- `GET /api/reservations/:id` - Get reservation details
- `GET /api/reservations` - List user reservations
- `PUT /api/reservations/:id` - Update reservation
- `DELETE /api/reservations/:id` - Cancel reservation
- `GET /api/reservations/:id/status` - Check reservation status
- `POST /api/reservations/:id/confirm` - Confirm reservation
- `POST /api/reservations/:id/payment` - Process payment

(Actual endpoints depend on your application implementation)

## Integration with Other Services

### Accommodation Service
The reservation-service integrates with accommodation-service for:
- Checking availability
- Retrieving accommodation details
- Updating availability calendars

### User Service
User authentication and profile information:
- Verifying user identity
- Retrieving guest information
- Managing user booking history

### Payment Service (if exists)
For processing payments:
- Payment gateway integration
- Transaction records
- Refund processing

### Notification Service (if exists)
For sending notifications:
- Booking confirmations
- Cancellation notices
- Reminder emails

## Troubleshooting

### Pod not starting

Check database connection:
```bash
kubectl logs -l app.kubernetes.io/name=reservation-service
kubectl describe pod -l app.kubernetes.io/name=reservation-service
```

### Database connection issues

Verify secret exists:
```bash
kubectl get secret <release-name>-reservation-postgresql
```

Check database host resolution:
```bash
kubectl exec -it <pod-name> -- nslookup <database-host>
```

### Service integration issues

Check service connectivity:
```bash
# From reservation-service pod
kubectl exec -it <pod-name> -- curl http://accommodation-service:8080/health
kubectl exec -it <pod-name> -- curl http://user-service:8080/health
```

### Payment processing issues

If using external payment gateway, ensure proper credentials are configured via `extraEnv`:

```yaml
extraEnv:
  - name: STRIPE_API_KEY
    valueFrom:
      secretKeyRef:
        name: payment-secrets
        key: stripe-api-key
  - name: PAYMENT_WEBHOOK_SECRET
    valueFrom:
      secretKeyRef:
        name: payment-secrets
        key: webhook-secret
```

## License

Copyright © 2025 Trubanb