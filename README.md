# AppDynamics APM Monitoring for Google Cloud Run - Python Applications

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Version](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![Google Cloud](https://img.shields.io/badge/platform-Google%20Cloud-blue.svg)](https://cloud.google.com/)
[![AppDynamics](https://img.shields.io/badge/monitoring-AppDynamics-orange.svg)](https://www.appdynamics.com/)

Complete automation scripts and guide for implementing **AppDynamics Application Performance Monitoring (APM)** on Python applications deployed in **Google Cloud Run**.

## 🎯 What This Project Does

This repository provides:
- **Automated deployment scripts** for Python applications in Google Cloud Run
- **AppDynamics APM integration** with comprehensive monitoring setup
- **Production-ready configurations** with best practices
- **Load testing and validation tools** for monitoring verification
- **Complete cleanup scripts** for easy resource management

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Developer     │───▶│  Cloud Run       │───▶│  AppDynamics        │
│   (Your Code)   │    │  (Containerized  │    │  Controller         │
│                 │    │   Python App)    │    │  (APM Dashboard)    │
└─────────────────┘    └──────────────────┘    └─────────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │ Artifact Registry│
                       │ (Docker Images)  │
                       └──────────────────┘
```

## 📋 Prerequisites

### Google Cloud Platform
- GCP project with billing enabled
- Required APIs enabled:
  - Cloud Run API
  - Cloud Build API  
  - Artifact Registry API
  - Container Registry API
- IAM permissions:
  - Cloud Run Admin
  - Artifact Registry Admin
  - Cloud Build Editor

### AppDynamics
- AppDynamics SaaS Controller account
- Controller hostname (e.g., `your-tenant.saas.appdynamics.com`)
- Account name and access key
- Appropriate license for APM monitoring

### Development Environment
- `gcloud` CLI installed and configured
- Docker installed and running
- Bash shell environment
- `curl` for testing endpoints

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Abhimanyu9988/gcp-cloudrun.git
cd gcp-cloudrun
```

### 2. Configure Environment Variables

Create your environment configuration file:

```bash
cp 0-set-env.sh.template 0-set-env.sh
```

Edit `0-set-env.sh` with your specific values:

```bash
#!/bin/bash

# GCP Configuration
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"                    # Change to your preferred region
export SERVICE_NAME="my-python-app"            # Your Cloud Run service name
export IMAGE_NAME="$SERVICE_NAME"
export REPOSITORY_NAME="python-apps"

# AppDynamics Configuration - REQUIRED TO UPDATE
export APPD_CONTROLLER_HOST="your-tenant.saas.appdynamics.com"
export APPD_CONTROLLER_PORT="443"
export APPD_ACCOUNT_NAME="your-account-name"
export APPD_ACCESS_KEY="your-access-key"      # Keep this secure!
export APPD_APPLICATION_NAME="Python-CloudRun-Demo"
export APPD_TIER_NAME="CloudRun-Python-Tier"
export APPD_NODE_NAME="CloudRun-Python-Node"
export APPD_AGENT_VERSION="25.8.0.8120"

echo "Environment variables configured successfully!"
echo "Project ID: $PROJECT_ID"
echo "AppDynamics Application: $APPD_APPLICATION_NAME"
```

### 3. Set Environment and Deploy

```bash
# Load environment variables
source 0-set-env.sh

# Deploy basic Cloud Run application
./1-deploy-cloudrun.sh

# Add AppDynamics APM monitoring
./2-add-python-agent.sh
```

### 4. Verify and Test

```bash
# Generate test traffic
./generate-load.sh

# Check deployment info
cat deployment-info.txt
```

### 5. Clean Up (Optional)

```bash
# Remove all resources when done
./cleanup.sh
```

## 📁 Project Structure

```
appd-cloudrun-python/
├── README.md                    # This file
├── 0-set-env.sh.template       # Environment configuration template
├── 1-deploy-cloudrun.sh        # Initial Cloud Run deployment
├── 2-add-python-agent.sh       # AppDynamics APM integration
├── cleanup.sh                  # Resource cleanup script
├── app/                        # Sample Python application
│   ├── app.py                  # Flask application with APM features
│   ├── requirements.txt        # Python dependencies
│   ├── Dockerfile             # Container definition
│   └── appdynamics.cfg        # AppDynamics agent configuration
├── generate-load.sh            # Load testing script (auto-generated)
├── deployment-info.txt         # Deployment details (auto-generated)
└── docs/                       # Additional documentation
    ├── TROUBLESHOOTING.md      # Common issues and solutions
    ├── CONFIGURATION.md        # Advanced configuration guide
    └── BEST_PRACTICES.md       # Production recommendations
```

## 🔧 Script Details

### `1-deploy-cloudrun.sh`
- Creates GCP Artifact Registry repository
- Builds and deploys basic Python Flask application
- Configures Cloud Run service with optimal settings
- Validates deployment and provides service URL

### `2-add-python-agent.sh`
- Installs AppDynamics Python agent in container
- Creates comprehensive APM configuration
- Implements robust error handling and fallback mechanisms
- Deploys instrumented application with monitoring
- Generates load testing scripts for validation

### `cleanup.sh`
- Removes Cloud Run service
- Deletes Docker images from Artifact Registry
- Cleans up local Docker resources
- Removes generated files and directories

## 🔍 Monitoring Features

### Automatic Detection
- **Business Transactions**: All Flask routes automatically detected
- **Database Queries**: SQL query performance (if applicable)
- **External Service Calls**: HTTP requests and API calls
- **Error Tracking**: Exception capture and stack traces

### Custom Endpoints
- `/health` - Service health check with AppDynamics status
- `/appd-debug` - AppDynamics agent debugging information
- `/api/users` - Sample API endpoint with performance simulation
- `/api/orders` - Another sample endpoint with different performance characteristics
- `/api/simulate-error` - Error simulation for testing error tracking
- `/api/load-test` - Configurable load testing endpoint

### Key Metrics Monitored
- Response time and throughput
- Error rates and exception details
- Memory and CPU usage patterns
- Business transaction flow maps
- Code-level performance visibility

## ⚙️ Configuration Options

### Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `PROJECT_ID` | GCP Project ID | Yes | `my-gcp-project` |
| `REGION` | GCP Region | Yes | `us-central1` |
| `SERVICE_NAME` | Cloud Run service name | Yes | `my-python-app` |
| `APPD_CONTROLLER_HOST` | AppDynamics controller URL | Yes | `tenant.saas.appdynamics.com` |
| `APPD_ACCOUNT_NAME` | AppDynamics account name | Yes | `customer1` |
| `APPD_ACCESS_KEY` | AppDynamics access key | Yes | `abcd1234...` |
| `APPD_APPLICATION_NAME` | Application name in controller | No | `Python-CloudRun-Demo` |
| `APPD_TIER_NAME` | Tier name in application | No | `CloudRun-Python-Tier` |
| `APPD_NODE_NAME` | Node name in tier | No | `CloudRun-Python-Node` |

### AppDynamics Configuration

The `appdynamics.cfg` file supports extensive customization:

```ini
[agent]
app = Your-Application-Name
tier = Your-Tier-Name
node = auto

[controller]
host = your-controller-host
port = 443
ssl = on
account = your-account-name
accesskey = your-access-key

[logging]
level = info                    # debug, info, warning, error
output_file = /tmp/appd/logs/python-agent.log
max_file_size = 10MB
max_backup_files = 5

[instrumentation]
enable_async = true
enable_flask = true
enable_django = true
enable_sqlalchemy = true
enable_requests = true
```

## 🚨 Troubleshooting

### Common Issues

#### 1. AppDynamics Agent Not Connecting
```bash
# Check agent logs
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')
curl "$SERVICE_URL/appd-debug"

# Verify credentials
echo "Controller: $APPD_CONTROLLER_HOST"
echo "Account: $APPD_ACCOUNT_NAME"
# Never echo the access key for security
```

#### 2. Package Installation Failures
```bash
# Check build logs
gcloud logging read "resource.type=build" --limit=20

# Try manual build
cd app && docker build --no-cache -t test-image .
```

#### 3. No Data in AppDynamics Controller
- Verify application and tier names match exactly
- Check network connectivity from Cloud Run to controller
- Ensure agent process is running in container
- Wait 5-10 minutes for initial data to appear

### Getting Help

1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Review Cloud Run logs: `gcloud logging read "resource.type=cloud_run_revision"`
3. Test connectivity: `curl -I https://your-controller-host`
4. Open an issue in this repository

## 📊 Expected Results

After successful deployment, you should see in AppDynamics Controller:

### Application Dashboard
- Application name and health status
- Business transaction list and performance metrics
- Flow map showing service architecture
- Error analysis and root cause information

### Performance Metrics
- **Response Time**: < 500ms for most transactions
- **Throughput**: Requests per minute
- **Error Rate**: < 1% under normal conditions
- **Apdex Score**: > 0.8 for good user experience

## 🔐 Security Considerations

### Sensitive Information
- Never commit `0-set-env.sh` with real credentials
- Use Google Secret Manager for production deployments
- Rotate access keys regularly
- Implement least-privilege IAM policies

### Production Recommendations
```bash
# Use Secret Manager
gcloud secrets create appd-access-key --data-file=key.txt

# Deploy with secrets
gcloud run deploy $SERVICE_NAME \
    --update-secrets="APPD_ACCESS_KEY=appd-access-key:latest"
```

## 📈 Performance Optimization

### Resource Allocation
```bash
# Optimize Cloud Run settings
gcloud run deploy $SERVICE_NAME \
    --memory=1Gi \
    --cpu=1 \
    --concurrency=100 \
    --max-instances=10 \
    --min-instances=1      # Reduce cold starts
```

### Agent Optimization
- Set appropriate logging levels
- Disable unnecessary instrumentation
- Configure sampling rates for high-traffic applications
- Monitor memory usage and adjust accordingly

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
```bash
# Fork the repository
git fork https://github.com/original-repo/appd-cloudrun-python.git

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and test
source 0-set-env.sh
./1-deploy-cloudrun.sh

# Submit pull request
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **AppDynamics** for comprehensive APM capabilities
- **Google Cloud** for serverless container platform
- **Python Flask** community for web framework
- Contributors and beta testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Abhimanyu9988/gcp-cloudrun/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Abhimanyu9988/gcp-cloudrun/discussions)
- **Documentation**: Check the `docs/` directory
- **AppDynamics Support**: [AppDynamics Documentation](https://docs.appdynamics.com/)


---

**⭐ Star this repository if it helped you implement APM monitoring for your Cloud Run applications!**

For questions or support, please open an issue or start a discussion in the repository.