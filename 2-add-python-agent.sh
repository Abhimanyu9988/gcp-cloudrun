#!/bin/bash

# AppDynamics Python Agent Integration Script (Updated with Timeout Fixes)
# This script modifies the existing Cloud Run application to include AppDynamics Python agent

set -e  # Exit on any error

# Configuration - Update these variables with your AppDynamics details
PROJECT_ID="${PROJECT_ID:-your-gcp-project-id}"
REGION="${REGION:-us-central1}"
SERVICE_NAME="${SERVICE_NAME:-python-app-demo}"
IMAGE_NAME="${IMAGE_NAME:-$SERVICE_NAME}"
REPOSITORY_NAME="${REPOSITORY_NAME:-python-apps}"

# AppDynamics Configuration - REQUIRED TO UPDATE
APPD_CONTROLLER_HOST="${APPD_CONTROLLER_HOST:-your-tenant.saas.appdynamics.com}"
APPD_CONTROLLER_PORT="${APPD_CONTROLLER_PORT:-443}"
APPD_ACCOUNT_NAME="${APPD_ACCOUNT_NAME:-your-account-name}"
APPD_ACCESS_KEY="${APPD_ACCESS_KEY:-your-access-key}"
APPD_APPLICATION_NAME="${APPD_APPLICATION_NAME:-Python-CloudRun-Demo}"
APPD_TIER_NAME="${APPD_TIER_NAME:-CloudRun-Python-Tier}"
APPD_AGENT_VERSION="${APPD_AGENT_VERSION:-25.6.0.7974}"

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

# Check AppDynamics configuration
check_appd_config() {
    log_info "Checking AppDynamics configuration..."
    
    if [[ "$APPD_CONTROLLER_HOST" == "your-tenant.saas.appdynamics.com" ]]; then
        log_error "Please update APPD_CONTROLLER_HOST with your actual AppDynamics controller hostname"
        exit 1
    fi
    
    if [[ "$APPD_ACCESS_KEY" == "your-access-key" ]]; then
        log_error "Please update APPD_ACCESS_KEY with your actual AppDynamics access key"
        exit 1
    fi
    
    if [[ "$APPD_ACCOUNT_NAME" == "your-account-name" ]]; then
        log_error "Please update APPD_ACCOUNT_NAME with your actual AppDynamics account name"
        exit 1
    fi
    
    log_info "AppDynamics configuration validated."
}

# Create AppDynamics configuration
create_appd_config() {
    log_info "Creating AppDynamics configuration..."
    
    # Create appdynamics.cfg
    cat > app/appdynamics.cfg << EOF
[agent]
app = $APPD_APPLICATION_NAME
tier = $APPD_TIER_NAME
node = auto

[controller]
host = $APPD_CONTROLLER_HOST
port = $APPD_CONTROLLER_PORT
ssl = on
account = $APPD_ACCOUNT_NAME
accesskey = $APPD_ACCESS_KEY

[logging]
level = info
output_file = /tmp/appd/logs/python-agent.log
max_file_size = 10MB
max_backup_files = 5

[proxy]
host = localhost
port = 8090

[instrumentation]
enable_async = true
enable_django = true
enable_flask = true
enable_sqlalchemy = true
enable_requests = true
enable_urllib3 = true
EOF

    log_info "AppDynamics configuration created."
}

# Create robust Dockerfile with timeout handling
create_instrumented_dockerfile() {
    log_info "Creating instrumented Dockerfile with timeout fixes..."
    
    cat > app/Dockerfile << EOF
FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /app

# Update system and install curl for troubleshooting
RUN apt-get update && apt-get install -y --no-install-recommends \\
    curl \\
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip first
RUN pip install --upgrade pip

# Install Flask first (lightweight and fast)
RUN pip install --no-cache-dir Flask==2.3.3

# Install AppDynamics with robust timeout and retry settings
RUN pip install --no-cache-dir \\
    --timeout=600 \\
    --retries=5 \\
    --index-url https://pypi.org/simple/ \\
    --trusted-host pypi.org \\
    --trusted-host pypi.python.org \\
    --trusted-host files.pythonhosted.org \\
    appdynamics==$APPD_AGENT_VERSION

# Copy application code and AppDynamics configuration
COPY app.py .
COPY appdynamics.cfg .

# Create directories for AppDynamics logs
RUN mkdir -p /tmp/appd/logs && chmod 777 /tmp/appd/logs

# Expose port
EXPOSE 8080

# Environment variables for AppDynamics
ENV APPDYNAMICS_AGENT_APPLICATION_NAME=$APPD_APPLICATION_NAME
ENV APPDYNAMICS_AGENT_TIER_NAME=$APPD_TIER_NAME
ENV APPDYNAMICS_CONTROLLER_HOST_NAME=$APPD_CONTROLLER_HOST
ENV APPDYNAMICS_CONTROLLER_PORT=$APPD_CONTROLLER_PORT
ENV APPDYNAMICS_CONTROLLER_SSL_ENABLED=true
ENV APPDYNAMICS_AGENT_ACCOUNT_NAME=$APPD_ACCOUNT_NAME
ENV APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=$APPD_ACCESS_KEY

# Run the application with AppDynamics pyagent
CMD ["pyagent", "run", "-c", "appdynamics.cfg", "--", "python", "app.py"]
EOF

    log_info "Robust Dockerfile created with timeout handling."
}

# Create fallback Dockerfile if main one fails
create_fallback_dockerfile() {
    log_info "Creating fallback Dockerfile (manual AppDynamics installation)..."
    
    cat > app/Dockerfile.fallback << EOF
FROM --platform=linux/amd64 python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \\
    curl \\
    wget \\
    && rm -rf /var/lib/apt/lists/*

# Install Flask
RUN pip install --no-cache-dir Flask==2.3.3

# Try alternative approach for AppDynamics - download wheel directly
RUN pip install --no-cache-dir \\
    --find-links https://pypi.org/simple/appdynamics/ \\
    --timeout=600 \\
    appdynamics==$APPD_AGENT_VERSION || \\
    pip install --no-cache-dir \\
    --index-url https://pypi.python.org/simple/ \\
    --timeout=600 \\
    appdynamics==$APPD_AGENT_VERSION

# Copy application and configuration
COPY app.py .
COPY appdynamics.cfg .

# Create AppDynamics directories
RUN mkdir -p /tmp/appd/logs && chmod 777 /tmp/appd/logs

# Expose port
EXPOSE 8080

# Environment variables for AppDynamics
ENV APPDYNAMICS_AGENT_APPLICATION_NAME=$APPD_APPLICATION_NAME
ENV APPDYNAMICS_AGENT_TIER_NAME=$APPD_TIER_NAME
ENV APPDYNAMICS_CONTROLLER_HOST_NAME=$APPD_CONTROLLER_HOST
ENV APPDYNAMICS_CONTROLLER_PORT=$APPD_CONTROLLER_PORT
ENV APPDYNAMICS_CONTROLLER_SSL_ENABLED=true
ENV APPDYNAMICS_AGENT_ACCOUNT_NAME=$APPD_ACCOUNT_NAME
ENV APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=$APPD_ACCESS_KEY

# Run with AppDynamics
CMD ["pyagent", "run", "-c", "appdynamics.cfg", "--", "python", "app.py"]
EOF

    log_info "Fallback Dockerfile created."
}

# Create enhanced application with custom metrics
create_enhanced_app() {
    log_info "Creating enhanced application with AppDynamics instrumentation..."
    
    cat > app/app.py << 'EOF'
from flask import Flask, jsonify, request
import os
import time
import random
import logging
import subprocess
import glob

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def check_appd_proxy():
    """Check if AppDynamics proxy is actually running"""
    try:
        # Check for proxy process
        result = subprocess.run(['pgrep', '-f', 'proxy'], capture_output=True, text=True)
        return len(result.stdout.strip()) > 0
    except:
        return False

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Cloud Run with AppDynamics!',
        'service': os.environ.get('K_SERVICE', 'unknown'),
        'revision': os.environ.get('K_REVISION', 'unknown'),
        'timestamp': time.time()
    })

@app.route('/health')
def health_check():
    # Actually check if the proxy process is running
    proxy_running = check_appd_proxy()
    appd_status = "enabled" if proxy_running else "disabled"
    
    return jsonify({
        'status': 'healthy', 
        'appd_status': appd_status,
        'appd_directory_exists': os.path.exists('/tmp/appd'),
        'timestamp': time.time()
    })

@app.route('/appd-logs')
def appd_logs():
    """Debug endpoint to read AppDynamics logs"""
    try:
        log_info = {}
        
        # List all files in /tmp/appd/logs
        if os.path.exists('/tmp/appd/logs'):
            log_files = glob.glob('/tmp/appd/logs/*')
            log_info['files'] = [os.path.basename(f) for f in log_files]
            
            # Read the most recent or main log files
            for log_file in log_files:
                if os.path.isfile(log_file) and os.path.getsize(log_file) > 0:
                    filename = os.path.basename(log_file)
                    try:
                        with open(log_file, 'r') as f:
                            # Read last 50 lines to avoid huge responses
                            lines = f.readlines()
                            log_info[filename] = lines[-50:] if len(lines) > 50 else lines
                    except Exception as e:
                        log_info[filename] = f"Error reading: {str(e)}"
        else:
            log_info['error'] = '/tmp/appd/logs directory does not exist'
            
        return jsonify(log_info)
        
    except Exception as e:
        return jsonify({'error': f'Failed to read AppD logs: {str(e)}'})

@app.route('/api/users')
def get_users():
    query_time = random.uniform(0.1, 0.5)
    time.sleep(query_time)
    
    users = [
        {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
        {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
        {'id': 3, 'name': 'Charlie', 'email': 'charlie@example.com'}
    ]
    
    logger.info(f"Retrieved {len(users)} users in {query_time:.3f}s")
    return jsonify(users)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    logger.info(f"Starting Flask app on port {port}")
    app.run(host='0.0.0.0', port=port, debug=False)
EOF

    log_info "Enhanced application created with AppDynamics instrumentation."
}

# Build and deploy with retry logic
build_and_deploy() {
    log_info "Building and deploying instrumented application..."
    
    cd app
    
    # Build the image with a new tag
    IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:appd-enabled"
    
    # Try main Dockerfile first
    log_info "Attempting build with primary Dockerfile..."
    if docker build --platform=linux/amd64 --network=host -t $IMAGE_URI . 2>&1; then
        log_info "✅ Primary build successful!"
    else
        log_warn "Primary build failed, trying fallback approach..."
        
        # Try fallback Dockerfile
        if [[ -f "Dockerfile.fallback" ]]; then
            mv Dockerfile Dockerfile.failed
            mv Dockerfile.fallback Dockerfile
            
            if docker build --platform=linux/amd64 --network=host -t $IMAGE_URI . 2>&1; then
                log_info "✅ Fallback build successful!"
            else
                log_error "Both primary and fallback builds failed. Check your network connection and try again."
                exit 1
            fi
        else
            log_error "Primary build failed and no fallback available."
            exit 1
        fi
    fi
    
    # Push the image
    log_info "Pushing image to registry..."
    docker push $IMAGE_URI
    
    cd ..
    
    # Deploy to Cloud Run with additional AppDynamics environment variables
    log_info "Deploying to Cloud Run..."
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
        --set-env-vars="ENVIRONMENT=production,APPD_ENABLED=true,APPDYNAMICS_AGENT_APPLICATION_NAME=$APPD_APPLICATION_NAME,APPDYNAMICS_AGENT_TIER_NAME=$APPD_TIER_NAME,APPDYNAMICS_AGENT_NODE_NAME=$APPD_NODE_NAME"
    # Get service URL
    SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')
    
    log_info "Instrumented service deployed successfully!"
    log_info "Service URL: $SERVICE_URL"
    
    # Test the deployment
    log_info "Testing the instrumented deployment..."
    sleep 15  # Give it more time to start up with AppDynamics
    
    if curl -f -s "$SERVICE_URL" > /dev/null; then
        log_info "✅ Instrumented service is responding correctly!"
        echo ""
        echo "🎯 Test your AppDynamics-instrumented endpoints:"
        echo "  Main: $SERVICE_URL"
        echo "  Health: $SERVICE_URL/health"
        echo "  Users API: $SERVICE_URL/api/users"
        echo "  Orders API: $SERVICE_URL/api/orders"
        echo "  Error Simulation: $SERVICE_URL/api/simulate-error"
        echo "  Load Test: $SERVICE_URL/api/load-test?operations=5&delay=0.2"
        echo ""
        echo "📊 Check your AppDynamics Controller in 5-10 minutes for:"
        echo "  - Application: $APPD_APPLICATION_NAME"
        echo "  - Tier: $APPD_TIER_NAME"
        echo "  - Business Transactions and Flow Maps"
        echo "  - Custom user data and error tracking"
    else
        log_warn "⚠️  Service deployed but not responding yet. Please wait a moment and try manually."
    fi
}

# Create a load test script for validation
create_load_test_script() {
    log_info "Creating load test script for AppDynamics validation..."
    
    SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')
    
    cat > generate-load.sh << EOF
#!/bin/bash

# Load test script to generate traffic for AppDynamics monitoring
SERVICE_URL="$SERVICE_URL"

echo "🚀 Generating load for AppDynamics monitoring..."
echo "Service URL: \$SERVICE_URL"
echo "Press Ctrl+C to stop"

# Function to make requests
make_requests() {
    while true; do
        # Normal requests
        curl -s "\$SERVICE_URL" > /dev/null
        sleep 1
        
        curl -s "\$SERVICE_URL/api/users" > /dev/null
        sleep 1
        
        curl -s "\$SERVICE_URL/api/orders" > /dev/null
        sleep 1
        
        # Some errors for testing
        curl -s "\$SERVICE_URL/api/simulate-error" > /dev/null
        sleep 1
        
        # Load test endpoint
        curl -s "\$SERVICE_URL/api/load-test?operations=3&delay=0.1" > /dev/null
        sleep 2
        
        echo "Generated batch of requests..."
    done
}

# Run load test
make_requests
EOF

    chmod +x generate-load.sh
    
    log_info "Load test script created: ./generate-load.sh"
}

# Main execution
main() {
    log_info "Starting AppDynamics Python Agent integration..."
    log_info "Project ID: $PROJECT_ID"
    log_info "Service Name: $SERVICE_NAME"
    log_info "AppDynamics Application: $APPD_APPLICATION_NAME"
    
    check_appd_config
    create_appd_config
    create_instrumented_dockerfile
    create_fallback_dockerfile
    create_enhanced_app
    build_and_deploy
    create_load_test_script
    
    log_info "🎉 AppDynamics Python Agent integration completed!"
    
    # Update deployment info
    cat >> deployment-info.txt << EOF

AppDynamics Python Agent Integration:
====================================
Controller Host: $APPD_CONTROLLER_HOST
Application Name: $APPD_APPLICATION_NAME
Tier Name: $APPD_TIER_NAME
Agent Version: $APPD_AGENT_VERSION
Image URI: $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:appd-enabled

Next Steps:
- Generate load with: ./generate-load.sh
- Check AppDynamics Controller for application data
- Run './3-add-machine-agent.sh' for infrastructure monitoring
EOF

    echo ""
    echo "📋 Important Notes:"
    echo "1. Data should appear in AppDynamics Controller within 5-10 minutes"
    echo "2. Run './generate-load.sh' to create traffic for testing"
    echo "3. Check the AppDynamics Controller for flowmaps and business transactions"
    echo "4. Monitor the logs if data doesn't appear: gcloud logging read \"resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME\" --limit=20"
}

# Run main function
main "$@"