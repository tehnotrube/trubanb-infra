# Rating Service Helm Chart

Helm chart for deploying the Trubanb Rating Service microservice.

## Overview

This chart deploys the rating-service application with:
- MongoDB database connection (database: `ratingsdb`)
- Kong Ingress for API Gateway routing
- Health checks (liveness & readiness probes)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- MongoDB database (deployed via umbrella chart)
- Kong Ingress Controller

## Installation

This chart is typically installed as part of the umbrella chart, but can be installed standalone:

```bash
helm install rating-service . \
  --set mongodb.host=my-mongodb \
  --set mongodb.existingSecret=my-mongodb-secret \
  --set image.tag=v1.0.0
```

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `ghcr.io/tehnotrube/rating-service` |
| `image.tag` | Image tag | `v1.0.0` |
| `mongodb.host` | MongoDB host (auto-generated if empty) | `""` |
| `mongodb.port` | MongoDB port | `27017` |
| `mongodb.database` | Database name | `ratingsdb` |
| `mongodb.existingSecret` | Secret containing MongoDB credentials | `""` |
| `ingress.enabled` | Enable ingress | `false` |

### MongoDB Configuration

The chart expects MongoDB credentials in a Kubernetes secret with keys:
- `mongodb-username` - Database username
- `mongodb-password` - User password
- `mongodb-root-password` - Root password (optional)

If `mongodb.existingSecret` is not provided, it defaults to `{{ .Release.Name }}-mongodb`

#### Connection String

The chart automatically constructs the MongoDB connection string:
```
mongodb://$(MONGODB_USERNAME):$(MONGODB_PASSWORD)@<host>:<port>/<database>?authSource=admin
```

Available as environment variable: `MONGODB_URI`

Individual components are also available:
- `MONGODB_HOST`
- `MONGODB_PORT`
- `MONGODB_DATABASE`
- `MONGODB_USERNAME` (from secret)
- `MONGODB_PASSWORD` (from secret)

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
mongodb:
  database: ratingsdb-dev
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

The rating-service uses MongoDB with the following collections:
- **ratings** - User ratings and reviews
- **aggregate_ratings** - Aggregated rating scores per accommodation
- **rating_stats** - Statistical data for analytics

The service handles schema creation automatically.

## API Endpoints

The service exposes:
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness check endpoint
- `POST /api/ratings` - Submit a rating
- `GET /api/ratings/:id` - Get rating details
- `GET /api/ratings/accommodation/:accommodationId` - Get ratings for accommodation
- `GET /api/ratings/user/:userId` - Get ratings by user
- `PUT /api/ratings/:id` - Update rating
- `DELETE /api/ratings/:id` - Delete rating
- `GET /api/ratings/stats/:accommodationId` - Get aggregated rating statistics

(Actual endpoints depend on your application implementation)

## Integration with Other Services

### User Service
Validates that ratings are submitted by authenticated users.

### Accommodation Service
Provides rating data to display average ratings and reviews for accommodations.

## MongoDB Best Practices

### Indexing
Ensure your application creates appropriate indexes:
```javascript
// Example indexes
db.ratings.createIndex({ "accommodationId": 1, "createdAt": -1 })
db.ratings.createIndex({ "userId": 1 })
db.ratings.createIndex({ "rating": 1 })
```

### Aggregation
Use MongoDB aggregation for calculating average ratings:
```javascript
db.ratings.aggregate([
  { $match: { accommodationId: "123" } },
  { $group: { 
    _id: "$accommodationId",
    avgRating: { $avg: "$rating" },
    count: { $sum: 1 }
  }}
])
```

## Troubleshooting

### Pod not starting

Check MongoDB connection:
```bash
kubectl logs -l app.kubernetes.io/name=rating-service
kubectl describe pod -l app.kubernetes.io/name=rating-service
```

### MongoDB connection issues

Verify secret exists:
```bash
kubectl get secret <release-name>-mongodb
kubectl get secret <release-name>-mongodb -o yaml
```

Check MongoDB host resolution:
```bash
kubectl exec -it <pod-name> -- nslookup <mongodb-host>
```

Test MongoDB connection:
```bash
kubectl exec -it <mongodb-pod> -- mongosh -u <username> -p <password>
```

### Performance issues

Monitor MongoDB performance:
```bash
# Check MongoDB logs
kubectl logs -l app.kubernetes.io/name=mongodb

# Check indexes
kubectl exec -it <mongodb-pod> -- mongosh ratingsdb --eval "db.ratings.getIndexes()"
```

## License

Copyright © 2025 Trubanb
