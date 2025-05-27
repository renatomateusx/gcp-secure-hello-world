#!/bin/bash

# Project Configuration
PROJECT_ID="smt-the-dev-rsantos-i5qi"
SERVICE_ACCOUNT="terraform@${PROJECT_ID}.iam.gserviceaccount.com"
REGION="us-central1"

# Output Colors Configuration
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper Functions
check_gcloud_auth() {
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
        echo -e "${RED}Error: You are not authenticated with Google Cloud.${NC}"
        echo "Please run: gcloud auth login"
        exit 1
    fi
}

check_project_config() {
    if ! gcloud config get-value project 2>/dev/null | grep -q "${PROJECT_ID}"; then
        echo -e "${RED}Error: Wrong project configured.${NC}"
        echo "Please run: gcloud config set project ${PROJECT_ID}"
        exit 1
    fi
}

# Main Script
echo "Starting setup script..."

# Check authentication and project configuration
check_gcloud_auth
check_project_config

# Configure IAM permissions
echo "Configuring IAM permissions..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/editor"

# Configure URL Map
echo "Configuring URL Map..."
gcloud compute url-maps create hello-world-url-map \
    --default-service=hello-world-backend-service \
    --project="${PROJECT_ID}"

# Configure additional permissions
echo "Configuring additional permissions..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/cloudfunctions.developer"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/iam.serviceAccountUser"

# Final verification
echo "Verifying configuration..."
if gcloud compute url-maps describe hello-world-url-map --project="${PROJECT_ID}" &>/dev/null; then
    echo -e "${GREEN}URL Map configuration verified successfully.${NC}"
else
    echo -e "${RED}Error: URL Map configuration failed.${NC}"
    exit 1
fi

# Conclusion
echo -e "${GREEN}Setup completed successfully!${NC}"
echo "You can now proceed with the deployment." 