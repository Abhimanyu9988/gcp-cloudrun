# Contributing to AppDynamics Cloud Run Python Monitoring

Thank you for your interest in contributing to this project! We welcome contributions from the community to help improve APM monitoring for Python applications on Google Cloud Run.

## 🤝 Ways to Contribute

- **🐛 Report bugs** and issues
- **✨ Suggest new features** or improvements
- **📖 Improve documentation**
- **🔧 Submit code improvements**
- **🧪 Add test cases**
- **📝 Share usage examples**

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:
- Google Cloud Platform account with appropriate permissions
- AppDynamics SaaS Controller access (for testing)
- Docker installed and configured
- `gcloud` CLI installed and authenticated
- Basic knowledge of Python, Flask, and containerization

### Development Setup

1. **Fork the Repository**
   ```bash
   # Fork the repository on GitHub
   # Then clone your fork
   git clone https://github.com/YOUR_USERNAME/gcp-cloudrun.git
   cd gcp-cloudrun
   ```

2. **Set Up Environment**
   ```bash
   # Copy and configure environment template
   cp 0-set-env.sh.template 0-set-env.sh
   
   # Edit with your test credentials (never commit this file!)
   vim 0-set-env.sh
   
   # Load environment
   source 0-set-env.sh
   ```

3. **Test the Current Setup**
   ```bash
   # Deploy and test current version
   ./1-deploy-cloudrun.sh
   ./2-add-python-agent.sh
   
   # Verify everything works
   ./generate-load.sh
   
   # Clean up
   ./cleanup.sh
   ```

## 📋 Development Workflow

### Creating Changes

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b bugfix/issue-description
   # or  
   git checkout -b docs/documentation-improvement
   ```

2. **Make Your Changes**
   - Follow the existing code style and patterns
   - Add comments for complex logic
   - Update documentation if needed
   - Test your changes thoroughly

3. **Test Your Changes**
   ```bash
   # Test deployment
   source 0-set-env.sh
   ./1-deploy-cloudrun.sh
   
   # Test AppDynamics integration
   ./2-add-python-agent.sh
   
   # Generate test traffic
   ./generate-load.sh
   
   # Verify in AppDynamics Controller
   # Check for any errors or issues
   
   # Clean up test resources
   ./cleanup.sh
   ```

### Commit Guidelines

We follow conventional commit messages:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
git commit -m "feat(deployment): add support for custom memory allocation"
git commit -m "fix(appd-agent): resolve agent connection timeout issues"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(scripts): improve error handling in deployment script"
```

### Pull Request Process

1. **Push Your Changes**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Go to GitHub and create a pull request
   - Use a clear, descriptive title
   - Fill out the pull request template
   - Link any related issues

3. **Pull Request Template**
   
   Your PR should include:
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Performance improvement
   - [ ] Code refactoring
   
   ## Testing
   - [ ] Tested locally with sample application
   - [ ] Verified AppDynamics data collection
   - [ ] Tested cleanup process
   - [ ] Updated documentation if needed
   
   ## Checklist
   - [ ] Code follows project style guidelines
   - [ ] Self-review completed
   - [ ] Comments added for complex logic
   - [ ] Documentation updated
   - [ ] No sensitive data in commits
   ```

## 🧪 Testing Guidelines

### Manual Testing

Always test your changes with:

1. **Basic Deployment Test**
   ```bash
   ./1-deploy-cloudrun.sh
   # Verify: Service deploys successfully
   # Verify: Endpoints respond correctly
   ```

2. **AppDynamics Integration Test**
   ```bash
   ./2-add-python-agent.sh
   # Verify: Agent installs without errors
   # Verify: Application appears in controller
   # Verify: Business transactions are detected
   ```

3. **Load Testing**
   ```bash
   ./generate-load.sh
   # Run for 5-10 minutes
   # Verify: Data flows to AppDynamics
   # Verify: No errors in Cloud Run logs
   ```

4. **Cleanup Test**
   ```bash
   ./cleanup.sh
   # Verify: All resources are removed
   # Verify: No lingering containers or images
   ```

### Test Environments

- Use separate GCP projects for testing
- Use AppDynamics trial/demo controllers when possible
- Clean up resources after testing to avoid charges

## 📝 Documentation Standards

### Code Documentation

- Add clear comments for complex logic
- Update script headers with change descriptions
- Document environment variables and configuration options

### README Updates

- Update README.md for new features
- Add troubleshooting steps for new issues
- Include examples for new functionality

### Configuration Changes

- Update `0-set-env.sh.template` for new variables
- Document configuration options in README
- Provide sensible defaults where possible

## 🐛 Bug Reports

When reporting bugs, please include:

### Issue Template
```markdown
## Bug Description
Clear description of the bug

## Environment
- OS: [e.g., macOS 12.0, Ubuntu 20.04]
- gcloud version: [output of `gcloud version`]
- Docker version: [output of `docker version`]
- AppDynamics agent version: [from script or logs]

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should have happened

## Actual Behavior
What actually happened

## Logs and Error Messages
```bash
# Include relevant logs
# Sanitize any sensitive information
```

## Additional Context
Any other relevant information
```

### Log Collection

When reporting issues, include relevant logs:

```bash
# Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=$SERVICE_NAME" --limit=20

# Docker build logs
gcloud logging read "resource.type=build" --limit=10

# Local script output
# Run scripts with verbose output and include relevant sections
```

## ✨ Feature Requests

We welcome feature requests! Please include:

- **Use case**: Why is this feature needed?
- **Description**: What should the feature do?
- **Implementation ideas**: Any thoughts on how to implement?
- **Alternatives**: Have you considered other approaches?

### Common Feature Areas

- **Monitoring enhancements**: Additional metrics, custom business transactions
- **Deployment improvements**: New Cloud Run configurations, scaling options
- **Framework support**: Django, FastAPI, other Python frameworks
- **Integration options**: CI/CD pipelines, Infrastructure as Code
- **Troubleshooting tools**: Better debugging, health checks

## 🎯 Code Review Process

### Review Criteria

Pull requests are reviewed for:

1. **Functionality**: Does it work as intended?
2. **Security**: No sensitive data, secure configurations
3. **Reliability**: Error handling, edge cases
4. **Maintainability**: Clear code, good documentation
5. **Performance**: Efficient resource usage
6. **Compatibility**: Works across different environments

### Review Timeline

- Initial review within 48-72 hours
- Follow-up reviews within 24 hours
- Merge after approval and successful testing

## 🏆 Recognition

Contributors will be:
- Listed in the README contributors section
- Mentioned in release notes for significant contributions
- Given credit in commit messages and pull request descriptions

## 📞 Getting Help

If you need help with contributing:

1. **GitHub Discussions**: Ask questions in repository discussions
2. **Issues**: Create an issue with the "question" label
3. **Documentation**: Check existing documentation and examples

## 📜 Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

### Our Standards

- **Be respectful** and inclusive
- **Be collaborative** and constructive
- **Focus on the best** for the community
- **Show empathy** towards other community members

## 🔐 Security

If you discover a security vulnerability, please:

1. **Don't** create a public issue
2. **Email** the maintainers directly
3. **Provide** detailed information about the vulnerability
4. **Wait** for a response before disclosing publicly

---

Thank you for contributing to make AppDynamics monitoring better for the Python and Cloud Run community! 🚀

For questions about contributing, please open an issue or start a discussion in the repository.