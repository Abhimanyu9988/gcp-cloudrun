#!/bin/bash

echo "🧹 Starting cleanup of AppDynamics Cloud Run Demo..."

# Source environment variables
if [ -f "0-set-env.sh" ]; then
    source 0-set-env.sh
else
    echo "❌ Environment file not found. Please ensure 0-set-env.sh exists."
    exit 1
fi

# Delete Cloud Run service
echo "🗑️ Deleting Cloud Run service..."
gcloud run services delete $SERVICE_NAME --region=$REGION --quiet

# Delete Docker images from Artifact Registry
echo "🗑️ Deleting Docker images..."
gcloud artifacts docker images delete $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:latest --quiet 2>/dev/null || true
gcloud artifacts docker images delete $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:appd-enabled --quiet 2>/dev/null || true
gcloud artifacts docker images delete $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:appd-debug-logs --quiet 2>/dev/null || true

# Delete Artifact Registry repository
echo "🗑️ Deleting Artifact Registry repository..."
gcloud artifacts repositories delete $REPOSITORY_NAME --location=$REGION --quiet

# Clean up local Docker images
echo "🗑️ Cleaning up local Docker images..."
docker system prune -af --filter "label=project=appd-demo" 2>/dev/null || true

# Remove local files
echo "🗑️ Cleaning up local files..."
rm -rf app/
rm -rf GCPCloudRun-AppD-Demo/

echo "✅ Cleanup completed successfully!"
echo "You can now run the complete setup script to recreate everything."