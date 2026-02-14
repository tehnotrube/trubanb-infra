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

This builds all 5 backend services and the frontend with the `local` tag.

To build a single service:
```powershell
.\build-local.ps1 frontend        # Build only frontend
.\build-local.ps1 user-service    # Build only user-service
```

#### Step 2: Add Helm Repositories

```bash
helm repo add kong https://charts.konghq.com
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
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

Kong API Gateway is the single entry point, exposed via NodePort on port **30080**.

- **Frontend**: `http://localhost:30080/`
- **API endpoints**:
  - `http://localhost:30080/api/users`
  - `http://localhost:30080/api/accommodations`
  - `http://localhost:30080/api/reservations`
  - `http://localhost:30080/api/ratings`
  - `http://localhost:30080/api/notifications`

### Observability Dashboards

Grafana and Jaeger are internal (ClusterIP) services. Access them via port-forwarding:

**Grafana:**
```bash
kubectl port-forward svc/trubanb-kube-prometheus-stack-grafana 3000:80 -n trubanb-dev
# Access at http://localhost:3000 (admin / admin123)
```

**Jaeger:**
```bash
kubectl port-forward svc/trubanb-jaeger-query 16686:16686 -n trubanb-dev
# Access at http://localhost:16686
```

### Upgrading

After making changes, upgrade the deployment:

```bash
helm upgrade trubanb . -f ../environments/values-local.yaml -n trubanb-dev
```

### Uninstalling

```bash
helm uninstall trubanb -n trubanb-dev
```