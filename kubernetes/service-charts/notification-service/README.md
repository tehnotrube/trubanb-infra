# Notification Service Helm Chart

Helm chart for deploying the Trubanb Notification Service microservice.

## Overview

This chart deploys the notification-service application with:
- Kong Ingress for API Gateway routing
- Health checks (liveness & readiness probes)
- Support for external notification providers (SMTP, SMS, Push notifications)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Kong Ingress Controller

## Installation

This chart is typically installed as part of the umbrella chart, but can be installed standalone:

```bash
helm install notification-service . \
  --set image.tag=v1.0.0
```

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/tehnotrube/notification-service` |
| `image.tag` | Image tag | `v1.0.0` |
| `service.port` | Service port | `3001` |
| `ingress.enabled` | Enable ingress | `false` |

### Environment Configuration

Configure external services via `extraEnv`:

```yaml
extraEnv:
  - name: SMTP_HOST
    value: "smtp.example.com"
  - name: SMTP_PORT
    value: "587"
  - name: SMTP_USER
    valueFrom:
      secretKeyRef:
        name: notification-secrets
        key: smtp-user
  - name: SMTP_PASSWORD
    valueFrom:
      secretKeyRef:
        name: notification-secrets
        key: smtp-password
```

## Health Checks

### Liveness Probe
- Path: `/api/notifications/health`
- Initial delay: 30s
- Period: 10s

### Readiness Probe
- Path: `/api/notifications/health`
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
  - name: LOG_LEVEL
    value: "info"
  - name: SMTP_HOST
    value: "smtp.sendgrid.net"
  - name: SMTP_PORT
    value: "587"
```

## API Endpoints

The service exposes:
- `GET /api/notifications/health` - Health check endpoint
- `POST /api/notifications/send` - Send notification
- `GET /api/notifications/:id` - Get notification status
- `GET /api/notifications` - List notifications
- `POST /api/notifications/email` - Send email notification
- `POST /api/notifications/sms` - Send SMS notification

(Actual endpoints depend on your application implementation)

## Integration with Other Services

### User Service
For retrieving user notification preferences and contact information

### Reservation Service
For sending booking confirmations and reminders

### Accommodation Service
For sending host notifications about new bookings

## Troubleshooting

### Pod not starting

Check logs:
```bash
kubectl logs -l app.kubernetes.io/name=notification-service
kubectl describe pod -l app.kubernetes.io/name=notification-service
```

### Email sending issues

Verify SMTP configuration:
```bash
kubectl exec -it <pod-name> -- env | grep SMTP
```

### Service integration issues

Check service connectivity:
```bash
# From notification-service pod
kubectl exec -it <pod-name> -- curl http://user-service:8080/health
```

## License

Copyright © 2025 Trubanb
