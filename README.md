# trubanb-infra

Infrastructure and deployment configuration for Trubanb microservices platform.

## Local Development Setup

Follow these steps to run the application locally on Kubernetes.

### Prerequisites

#### 1. Clone All Services

Ensure you have all service repositories cloned in the same parent directory:

```
trubanb/
├── trubanb-frontend/
├── trubanb-user-service/
├── trubanb-accommodation-service/
├── trubanb-reservation-service/
├── trubanb-rating-service/
├── trubanb-notification-service/
└── trubanb-infra/
```

#### 2. Local Kubernetes Cluster

You need a local Kubernetes cluster running and configured. Choose one of the following:

- **Docker Desktop** - Enable Kubernetes in Docker Desktop settings
- **Minikube** - `minikube start`
- **Kind** - `kind create cluster`

Verify your cluster is running:

```bash
kubectl cluster-info
```

#### 3. Install Helm

**Windows (winget):**
```powershell
winget install Helm.Helm
```

**macOS (Homebrew):**
```bash
brew install helm
```

**Linux:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify Helm installation:

```bash
helm version
```

### Installation Steps

#### Step 1: Build Docker Images

From the `trubanb-infra/scripts` directory, run the build script to build all microservice images:

**PowerShell (Windows):**
```powershell
.\build-local.ps1
```

**Bash (Linux/macOS/Git Bash):**
```bash
chmod +x build-local.sh
./build-local.sh
```

This builds all 5 services with the `local` tag.

#### Step 2: Add Helm Repositories

```bash
helm repo add kong https://charts.konghq.com
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add minio https://charts.min.io/
helm repo update
```

#### Step 3: Build Helm Dependencies

Navigate to the umbrella chart directory and build dependencies:

```bash
cd kubernetes/umbrella-chart
helm dependency build
```

#### Step 4: Install to Kubernetes

Install the application to the `trubanb-dev` namespace:

```bash
helm install trubanb . -f ../environments/values-local.yaml --create-namespace --namespace trubanb-dev
```

### Verify Installation

Check that all pods are running:

```bash
kubectl get pods -n trubanb-dev
```

### Accessing the Application

Kong API Gateway is exposed via NodePort on port **30080**.

API endpoints are available at:
- `http://localhost:30080/api/users`
- `http://localhost:30080/api/accommodations`
- `http://localhost:30080/api/reservations`
- `http://localhost:30080/api/ratings`
- `http://localhost:30080/api/notifications`

Observability dashboards:
- **Grafana**: `http://localhost:30300` (admin / admin123)
- **Jaeger**: `http://localhost:30686`

### Upgrading

After making changes, upgrade the deployment:

```bash
helm upgrade trubanb . -f ../environments/values-local.yaml -n trubanb-dev
```

### Uninstalling

```bash
helm uninstall trubanb -n trubanb-dev
```