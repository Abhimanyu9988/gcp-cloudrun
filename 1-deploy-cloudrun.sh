#!/bin/bash

# GCP Cloud Run Deployment Script (Updated)
# This script sets up GCP Cloud Run and deploys a sample Python Flask application

set -e  # Exit on any error

# Configuration - Update these variables
PROJECT_ID="${PROJECT_ID:-your-gcp-project-id}"
REGION="${REGION:-us-central1}"
SERVICE_NAME="${SERVICE_NAME:-python-app-demo}"
IMAGE_NAME="${IMAGE_NAME:-$SERVICE_NAME}"
REPOSITORY_NAME="${REPOSITORY_NAME:-python-apps}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v gcloud &> /dev/null; then
        log_error "gcloud CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    log_info "Prerequisites check completed."
}

# Configure GCP project
configure_gcp() {
    log_info "Configuring GCP project..."
    
    # Set the project
    gcloud config set project $PROJECT_ID
    
    # Enable required APIs
    log_info "Enabling required GCP APIs..."
    gcloud services enable cloudbuild.googleapis.com
    gcloud services enable run.googleapis.com
    gcloud services enable artifactregistry.googleapis.com
    gcloud services enable containerregistry.googleapis.com
    
    # Configure Docker for GCP
    gcloud auth configure-docker $REGION-docker.pkg.dev
    
    log_info "GCP configuration completed."
}

# Create Artifact Registry repository
create_repository() {
    log_info "Creating Artifact Registry repository..."
    
    # Check if repository already exists
    if gcloud artifacts repositories describe $REPOSITORY_NAME --location=$REGION &> /dev/null; then
        log_warn "Repository $REPOSITORY_NAME already exists, skipping creation."
    else
        gcloud artifacts repositories create $REPOSITORY_NAME \
            --repository-format=docker \
            --location=$REGION \
            --description="Repository for Python applications"
        log_info "Repository created successfully."
    fi
}

# Create sample Python application
create_sample_app() {
    log_info "Creating sample Python Flask application..."
    
    # Create application directory
    mkdir -p app
    
    # Create main application file
    cat > app/app.py << 'EOF'
from flask import Flask, jsonify, request
import os
import time
import random
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Cloud Run!',
        'service': os.environ.get('K_SERVICE', 'unknown'),
        'revision': os.environ.get('K_REVISION', 'unknown'),
        'timestamp': time.time()
    })

@app.route('/health')
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': time.time()})

@app.route('/api/users')
def get_users():
    # Simulate some processing time
    time.sleep(random.uniform(0.1, 0.5))
    
    users = [
        {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
        {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
        {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com'}
    ]
    
    logger.info(f"Retrieved {len(users)} users")
    return jsonify(users)

@app.route('/api/orders')
def get_orders():
    # Simulate database query time
    time.sleep(random.uniform(0.2, 0.8))
    
    orders = [
        {'id': 101, 'user_id': 1, 'amount': 29.99, 'status': 'completed'},
        {'id': 102, 'user_id': 2, 'amount': 45.50, 'status': 'pending'},
        {'id': 103, 'user_id': 1, 'amount': 12.75, 'status': 'shipped'}
    ]
    
    logger.info(f"Retrieved {len(orders)} orders")
    return jsonify(orders)

@app.route('/api/simulate-error')
def simulate_error():
    # Simulate random errors for testing
    if random.random() < 0.3:  # 30% chance of error
        logger.error("Simulated error occurred")
        return jsonify({'error': 'Something went wrong!'}), 500
    
    return jsonify({'message': 'Success!'})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
EOF

    # Create requirements file
    cat > app/requirements.txt << 'EOF'
Flask==2.3.3
EOF

    # Create Dockerfile with architecture fix
    cat > app/Dockerfile << 'EOF'
FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py .

# Expose port
EXPOSE 8080

# Use Python directly
CMD ["python", "app.py"]
EOF

    log_info "Sample application created successfully."
}

# Build and push Docker image
build_and_push_image() {
    log_info "Building and pushing Docker image..."
    
    cd app
    
    # Build the image with correct architecture
    IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:latest"
    
    docker build --platform=linux/amd64 -t $IMAGE_URI .
    
    # Push the image
    docker push $IMAGE_URI
    
    cd ..
    
    log_info "Image built and pushed successfully: $IMAGE_URI"
}

# Deploy to Cloud Run
deploy_to_cloudrun() {
    log_info "Deploying to Cloud Run..."
    
    IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:latest"
    
    gcloud run deploy $SERVICE_NAME \
        --image=$IMAGE_URI \
        --platform=managed \
        --region=$REGION \
        --allow-unauthenticated \
        --memory=1Gi \
        --cpu=1 \
        --concurrency=100 \
        --max-instances=10 \
        --port=8080 \
        --timeout=300 \
        --set-env-vars="ENVIRONMENT=production"
    
    # Get service URL
    SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')
    
    log_info "Service deployed successfully!"
    log_info "Service URL: $SERVICE_URL"
    
    # Test the deployment
    log_info "Testing the deployment..."
    
    if curl -f -s "$SERVICE_URL" > /dev/null; then
        log_info "✅ Service is responding correctly!"
        echo "Test your endpoints:"
        echo "  Main: $SERVICE_URL"
        echo "  Health: $SERVICE_URL/health"
        echo "  Users API: $SERVICE_URL/api/users"
        echo "  Orders API: $SERVICE_URL/api/orders"
        echo "  Error Simulation: $SERVICE_URL/api/simulate-error"
    else
        log_warn "⚠️  Service deployed but not responding yet. Please wait a moment and try manually."
    fi
}

# Main execution
main() {
    log_info "Starting GCP Cloud Run deployment..."
    log_info "Project ID: $PROJECT_ID"
    log_info "Region: $REGION"
    log_info "Service Name: $SERVICE_NAME"
    
    check_prerequisites
    configure_gcp
    create_repository
    create_sample_app
    build_and_push_image
    deploy_to_cloudrun
    
    log_info "🎉 Deployment completed successfully!"
    
    # Save deployment info
    cat > deployment-info.txt << EOF
Deployment Information:
======================
Project ID: $PROJECT_ID
Region: $REGION
Service Name: $SERVICE_NAME
Image URI: $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:latest
Service URL: $(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')

Next Steps:
- Run 'source 0-set-env.sh && ./2-add-python-agent-updated.sh' to add AppDynamics APM monitoring
- Run './3-add-machine-agent.sh' to add infrastructure monitoring
- Run './4-cleanup.sh' to remove all resources when done
EOF

    log_info "Deployment info saved to deployment-info.txt"
}

# Run main function
main "$@"