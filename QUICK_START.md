# 🚀 Quick Setup Guide

Get AppDynamics APM monitoring running on Google Cloud Run in under 10 minutes!

## Prerequisites Checklist

Before you start, make sure you have:

- [ ] **Google Cloud Project** with billing enabled
- [ ] **AppDynamics SaaS Controller** account and credentials
- [ ] **gcloud CLI** installed and authenticated (`gcloud auth login`)
- [ ] **Docker** installed and running (`docker --version`)

## Step 1: Get Your AppDynamics Credentials

You'll need these from your AppDynamics Controller:

1. **Controller Host**: `your-tenant.saas.appdynamics.com`
2. **Account Name**: Found in Controller UI → Settings → License → Account
3. **Access Key**: Generate from Controller UI → Settings → License → Account → Access Key

## Step 2: Configure Environment

```bash
# Clone the repository
git clone https://github.com/Abhimanyu9988/gcp-cloudrun.git
cd gcp-cloudrun

# Copy and edit environment file
cp 0-set-env.sh.template 0-set-env.sh

# Edit with your actual values
nano 0-set-env.sh
# or
vim 0-set-env.sh
```

**Required changes in `0-set-env.sh`:**
```bash
export PROJECT_ID="your-actual-gcp-project"
export APPD_CONTROLLER_HOST="your-tenant.saas.appdynamics.com"
export APPD_ACCOUNT_NAME="your-account-name"
export APPD_ACCESS_KEY="your-access-key"
```

## Step 3: Deploy and Monitor

```bash
# Load your configuration
source 0-set-env.sh

# Deploy basic Cloud Run application (2-3 minutes)
./1-deploy-cloudrun.sh

# Add AppDynamics monitoring (3-5 minutes)
./2-add-python-agent.sh

# Generate test traffic
./generate-load.sh
```

## Step 4: Verify in AppDynamics

1. **Open AppDynamics Controller** in your browser
2. **Look for your application**: `Python-CloudRun-Demo` (or your custom name)
3. **Check Business Transactions**: Should see Flask endpoints automatically detected
4. **View Flow Maps**: Visual representation of your application

**Data appears within 5-10 minutes of deployment.**

## Step 5: Clean Up (When Done)

```bash
# Remove all resources to avoid charges
./cleanup.sh
```

## 🎯 Expected Results

After successful setup, you'll see in AppDynamics:

### Application Dashboard
- ✅ Application: `Python-CloudRun-Demo`
- ✅ Tier: `CloudRun-Python-Tier`
- ✅ Nodes: Auto-generated for each Cloud Run instance

### Business Transactions
- ✅ `GET /` - Homepage
- ✅ `GET /health` - Health check
- ✅ `GET /api/users` - Users API
- ✅ `GET /api/orders` - Orders API
- ✅ `GET /api/simulate-error` - Error simulation

### Key Metrics
- 📊 Response times and throughput
- 🚨 Error rates and exceptions
- 🗺️ Service flow maps
- 🔍 Code-level visibility

## 🚨 Quick Troubleshooting

### Issue: No data in AppDynamics
**Solution:**
```bash
# Check agent status
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format='value(status.url)')
curl "$SERVICE_URL/appd-debug"

# Check Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision" --limit=10
```

### Issue: Script fails during deployment
**Solution:**
```bash
# Check gcloud authentication
gcloud auth list

# Verify project permissions
gcloud projects get-iam-policy $PROJECT_ID

# Enable required APIs
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com
```

### Issue: Docker build fails
**Solution:**
```bash
# Check Docker daemon
docker info

# Try manual build
cd app
docker build --no-cache -t test-build .
```

## 📱 Test Your Setup

### Health Check
```bash
curl "$SERVICE_URL/health"
# Expected: {"status": "healthy", "appd_agent_status": "enabled"}
```

### Generate Load
```bash
# The generate-load.sh script will create traffic to all endpoints
./generate-load.sh
# Let it run for 5-10 minutes to see data in AppDynamics
```

### Check AppDynamics Debug
```bash
curl "$SERVICE_URL/appd-debug"
# Shows AppDynamics agent configuration and status
```

## 🔄 Configuration Tips

### Change Application Name
```bash
# In 0-set-env.sh
export APPD_APPLICATION_NAME="MyApp-Production"
export APPD_TIER_NAME="Web-Tier"

# Redeploy
./2-add-python-agent.sh
```

### Adjust Resources
```bash
# In 2-add-python-agent.sh, modify:
gcloud run deploy $SERVICE_NAME \
    --memory=2Gi \        # Increase memory
    --cpu=2 \            # Increase CPU
    --max-instances=20   # Allow more scaling
```

## 📞 Need Help?

1. **Check the logs**: `gcloud logging read "resource.type=cloud_run_revision" --limit=20`
2. **Review documentation**: Full README.md and troubleshooting guides
3. **Open an issue**: Create GitHub issue with logs and error messages
4. **Community support**: GitHub Discussions for questions

## 🎉 Success!

If you see data flowing in AppDynamics Controller, congratulations! You've successfully set up APM monitoring for your Cloud Run application.

### Next Steps:
- **Customize monitoring**: Add custom business transactions and metrics
- **Set up alerts**: Configure performance and error alerts in AppDynamics
- **Scale up**: Deploy your own applications using this as a template
- **Infrastructure monitoring**: Add Machine Agent for complete observability

---

**⭐ Don't forget to star the repository if this helped you!**

For detailed information, see the complete [README.md](README.md) and [documentation](docs/).