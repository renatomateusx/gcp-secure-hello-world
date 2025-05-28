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

## Project Structure and Naming Convention

The project follows a specific naming convention as required in the assessment guide:

1. **Project ID Format:**
   ```
   smt-the-{env}-{yourname}-{random4char}
   ```
   Where:
   - `{env}`: Environment (dev, tst, prd)
   - `{yourname}`: Your name (3-10 characters)
   - `{random4char}`: Random 4 characters generated during deployment

2. **Project Creation:**
   - The project is automatically created in the `core_infra` module
   - The random suffix ensures unique project IDs
   - The project ID is generated using Terraform's `random_string` resource

3. **Project ID Access:**
   - The project ID is created in the `core_infra` module
   - It's exposed as an output variable
   - Other modules access it through module references
   - The ID is used to:
     - Configure the Cloud Function
     - Set up the Load Balancer
     - Configure monitoring
     - Set up security policies

4. **Example Project ID:**
   ```
   smt-the-dev-john-abc1
   ```

## First Time Setup

### 1. Initial GCP Configuration

1. **Set up GCP Project:**
   ```bash
   # Login to GCP
   gcloud auth login
   
   # List available billing accounts
   gcloud billing accounts list
   ```

2. **Get Billing Account ID:**
   - Copy the billing account ID from the command output above
   - Format will be like: `XXXXXX-XXXXXX-XXXXXX`

### 2. Local Environment Setup

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd gcp-hello-world
   ```

2. **Configure Environment Variables:**
   - Copy the example variables file:
     ```bash
     cp terraform/environments/dev.tfvars.example terraform/environments/dev.tfvars.local
     ```
   - Edit the file `terraform/environments/dev.tfvars.local`:
     ```hcl
     # Required variables
     environment = "dev"        # Choose: dev, tst, or prd
     your_name   = "your-name"  # 3-10 characters, will be used in project ID
     billing_account_id = "your-billing-account-id"  # From gcloud billing accounts list

     # Optional variables (defaults shown)
     region      = "us-central1"
     zone        = "us-central1-a"
     function_source_dir = "../function"
     ```

   > **Note:** The project ID will be automatically generated in the format `smt-the-{env}-{yourname}-{random4char}`. You don't need to set it manually.

   > **Changing Project Name:** If you need to change the project name after creation:
   > 1. Update the `your_name` variable in your `.tfvars` file
   > 2. Run `terraform destroy` to remove the old project
   > 3. Run `terraform apply` to create a new project with the updated name
   > 
   > Note: This will create a new project with a new random suffix. The old project will be abandoned (not deleted) as per the assessment requirements.

3. **Configure GCP Authentication:**
   ```bash
   # Set up application default credentials
   gcloud auth application-default login
   ```

### 3. First Deployment

1. **Initialize Terraform:**
   ```bash
   cd terraform
   terraform init
   ```

2. **Apply Configuration:**
   ```bash
   # Use your local variables file
   terraform apply -var-file=environments/dev.tfvars.local
   ```

3. **Check Outputs:**
   - After deployment, Terraform will show:
     - Load Balancer URL
     - Cloud Function URL
     - Created Project ID

### 4. Initial Testing

1. **Run Basic Test:**
   ```bash
   cd ..
   bash test/bash/test.bash
   ```

2. **Check Dashboard:**
   - Access GCP Console
   - Go to Monitoring > Dashboards
   - Look for "Hello World Application Dashboard"

### 5. Cleanup (if needed)

```bash
cd terraform
terraform destroy -var-file=environments/dev.tfvars.local
```

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
cd terraform
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
cd terraform
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