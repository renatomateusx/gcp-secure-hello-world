# GCP Hello World with Load Balancer

This project demonstrates a secure and scalable implementation of a "Hello World" application using Google Cloud Platform (GCP) services. It showcases best practices for deploying serverless applications with proper security controls and infrastructure as code.

## Architecture

The solution uses the following GCP services:

- **Cloud Functions**: Hosts the "Hello World" application
- **Global HTTP(S) Load Balancer**: Provides a single entry point with security controls
- **Serverless NEG**: Connects the Load Balancer to the Cloud Function
- **Security Policy**: Implements WAF (Web Application Firewall) rules
- **IAM**: Manages access control and permissions

### Why This Architecture?

1. **Security First**:
   - Direct access to Cloud Function is blocked
   - All traffic goes through a Load Balancer with WAF
   - Protection against SQL Injection and XSS attacks
   - Fine-grained IAM controls

2. **Scalability**:
   - Serverless architecture automatically scales
   - Global Load Balancer provides worldwide access
   - No infrastructure management required

3. **Cost-Effective**:
   - Pay only for what you use
   - No idle resources
   - Automatic scaling down to zero

4. **Maintainability**:
   - Infrastructure as Code using Terraform
   - Automated testing with Terratest
   - Clear separation of concerns

## Prerequisites

- Google Cloud Platform account
- Terraform >= 1.0.0
- Go >= 1.16 (for running tests)
- gcloud CLI

## Implementation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd gcp-hello-world
```

### 2. Configure GCP Authentication

```bash
# Set up application default credentials
gcloud auth application-default login

# Or use a service account key
export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account-key.json"
```

### 3. Deploy the Infrastructure

```bash
# Initialize Terraform
terraform init

# Apply the configuration
terraform apply -var-file=environments/dev.tfvars
```

## Testing and Metrics Collection

### How to Run Integration Tests

You can run automated tests to validate the Load Balancer and Cloud Function behavior:

**Quick test (basic checks):**
```bash
bash test/bash/test.bash
```
- This script will:
  - Test GET and POST requests to the Load Balancer
  - Test direct access to the Cloud Function
  - Simulate XSS and SQL Injection attacks
  - Show results directly in the terminal

**Full integration test with report:**
```bash
bash test/bash/test.sh
```
- This script will:
  - Run all integration tests (GET, POST, direct access, rate limiting, XSS, SQLi)
  - Collect Cloud Monitoring metrics and Cloud Logging logs
  - Generate a Markdown report in the `reports/` folder (and PDF if `pandoc` is installed)

### How to Collect Metrics and Logs

- **Cloud Monitoring metrics** are automatically collected by the test script (`test.sh`).
  - You can also view metrics in the GCP Console under Monitoring > Metrics Explorer.
- **Cloud Logging logs** are also collected by the test script.
  - You can view logs in the GCP Console under Logging > Log Explorer.

**Manual collection example:**
```bash
gcloud monitoring time-series list --filter="metric.type=\"cloudfunctions.googleapis.com/function/execution_count\""
gcloud logging read "resource.type=cloud_function" --limit=10 --format="table(timestamp,severity,textPayload)"
```

### Continuous Monitoring

To monitor the service in real time, you can run:
```bash
bash test/bash/monitor.sh
```
This script will periodically check the health of the service, collect metrics, and look for errors in the logs.

---

For any issues or to customize the tests, edit the scripts in `test/bash/` as needed.

## Security Features

1. **Load Balancer Security Policy**:
   - Allows access to `/helloWorld` endpoint
   - Blocks SQL Injection attempts
   - Blocks XSS attacks
   - Denies all other requests

2. **Cloud Function Security**:
   - Direct access blocked
   - Only accessible through Load Balancer
   - IAM roles for service accounts

3. **Network Security**:
   - Serverless NEG for secure communication
   - No public IPs exposed
   - HTTPS support (optional)

## Monitoring and Logging

- Cloud Logging enabled for the Load Balancer
- Function execution logs available in Cloud Logging
- Security policy violations are logged

## Cleanup

To remove all resources:

```bash
terraform destroy -var-file=environments/dev.tfvars
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.