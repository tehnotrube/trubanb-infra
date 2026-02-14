#!/bin/bash
# Build Script for Trubanb Microservices
# This script builds all 5 microservices with the 'local' tag for use with Docker Desktop Kubernetes
# Run from: trubanb-infra directory
# Usage: ./build-local.sh [ServiceName]
# Examples:
#   ./build-local.sh                    # Build all services
#   ./build-local.sh user-service       # Build only user-service

set -e

# Colors
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}  Trubanb Local Build Script${NC}"
echo -e "${CYAN}========================================${NC}\n"

# Get the root directory (parent of trubanb-infra)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Service definitions
declare -a SERVICE_NAMES=("User Service" "Accommodation Service" "Reservation Service" "Rating Service" "Notification Service" "Frontend")
declare -a SERVICE_PATHS=("$ROOT_DIR/trubanb-user-service" "$ROOT_DIR/trubanb-accommodation-service" "$ROOT_DIR/trubanb-reservation-service" "$ROOT_DIR/trubanb-rating-service" "$ROOT_DIR/trubanb-notification-service" "$ROOT_DIR/trubanb-frontend")
declare -a SERVICE_IMAGES=("trubanb-user-service:local" "trubanb-accommodation-service:local" "trubanb-reservation-service:local" "trubanb-rating-service:local" "trubanb-notification-service:local" "trubanb-frontend:local")
declare -a SERVICE_SHORT_NAMES=("user-service" "accommodation-service" "reservation-service" "rating-service" "notification-service" "frontend")

SERVICE_NAME="$1"
declare -a BUILD_INDICES=()

# Filter services if specific service name provided
if [ -n "$SERVICE_NAME" ]; then
    found=false
    for i in "${!SERVICE_SHORT_NAMES[@]}"; do
        if [ "${SERVICE_SHORT_NAMES[$i]}" == "$SERVICE_NAME" ]; then
            BUILD_INDICES+=("$i")
            found=true
            break
        fi
    done

    if [ "$found" = false ]; then
        echo -e "${RED}Error: Service '$SERVICE_NAME' not found${NC}"
        echo -e "${YELLOW}Available services:${NC}"
        for short_name in "${SERVICE_SHORT_NAMES[@]}"; do
            echo -e "${GRAY}  - $short_name${NC}"
        done
        exit 1
    fi

    echo -e "${CYAN}Building single service: $SERVICE_NAME${NC}\n"
else
    for i in "${!SERVICE_SHORT_NAMES[@]}"; do
        BUILD_INDICES+=("$i")
    done
    echo -e "${CYAN}Building all services${NC}\n"
fi

SUCCESS_COUNT=0
declare -a FAILED_SERVICES=()
TOTAL_COUNT=${#BUILD_INDICES[@]}

for i in "${BUILD_INDICES[@]}"; do
    name="${SERVICE_NAMES[$i]}"
    path="${SERVICE_PATHS[$i]}"
    image="${SERVICE_IMAGES[$i]}"

    echo -e "${YELLOW}Building $name...${NC}"
    echo -e "${GRAY}  Path: $path${NC}"
    echo -e "${GRAY}  Image: $image${NC}"

    if docker build -t "$image" "$path" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ $name built successfully${NC}\n"
        ((SUCCESS_COUNT++))
    else
        echo -e "${RED}  ✗ Failed to build $name${NC}\n"
        FAILED_SERVICES+=("$name")
    fi
done

echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}  Build Summary${NC}"
echo -e "${CYAN}========================================${NC}\n"

if [ "$SUCCESS_COUNT" -eq "$TOTAL_COUNT" ]; then
    echo -e "${GREEN}Successfully built: $SUCCESS_COUNT/$TOTAL_COUNT services${NC}"
else
    echo -e "${YELLOW}Successfully built: $SUCCESS_COUNT/$TOTAL_COUNT services${NC}"
fi

if [ ${#FAILED_SERVICES[@]} -gt 0 ]; then
    echo -e "${RED}Failed services:${NC}"
    for failed in "${FAILED_SERVICES[@]}"; do
        echo -e "${RED}  - $failed${NC}"
    done
    echo ""
    exit 1
fi

echo -e "\n${GREEN}All images built successfully!${NC}\n"

echo -e "${CYAN}Next steps:${NC}"
echo -e "${GRAY}  1. Verify images: ${WHITE}docker images | grep 'trubanb'${NC}"
echo -e "${GRAY}  2. Deploy to Kubernetes:${NC}"
echo -e "${WHITE}     cd kubernetes/umbrella-chart${NC}"
echo -e "${WHITE}     helm upgrade --install trubanb . -f ../environments/values-local.yaml --create-namespace --namespace trubanb-dev${NC}"
echo -e "${GRAY}  3. Check deployment: ${WHITE}kubectl get pods -n trubanb-dev${NC}"
echo ""