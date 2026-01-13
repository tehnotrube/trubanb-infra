#!/bin/bash
set -e

SCRIPT_DIR=$(basename "$PWD")
PARENT_DIR=$(basename "$(dirname "$PWD")")

if [ "$SCRIPT_DIR" = "scripts" ] && [ "$PARENT_DIR" = "trubanb-infra" ]; then
  cd ../..
fi

REPOS=(
  "https://github.com/tehnotrube/trubanb-infra.git"
  "https://github.com/tehnotrube/trubanb-user-service.git"
  "https://github.com/tehnotrube/trubanb-accommodation-service.git"
  "https://github.com/tehnotrube/trubanb-reservation-service.git"
  "https://github.com/tehnotrube/trubanb-rating-service.git"
  "https://github.com/tehnotrube/trubanb-notification-service.git"
  "https://github.com/tehnotrube/trubanb-frontend.git"
)

for repo in "${REPOS[@]}"; do
  NAME=$(basename "$repo" .git)
  if [ -d "$NAME" ]; then
    echo "[SKIP] $NAME already exists."
  else
    echo "[CLONE] $NAME"
    git clone "$repo"
  fi
done

echo "Done."
