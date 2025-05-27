/**

 * Terratest for GCP Hello World Infrastructure

 * 

 * This file contains automated tests for validating the deployed infrastructure.

 * It tests:

 * 1. Successful Terraform apply

 * 2. HTTP GET request to Load Balancer (should return 200 with "Hello World")

 * 3. HTTP POST request to Load Balancer (should return 405)

 * 4. Direct access to Cloud Function (should return 401/403)

 */

 package test

 import (
 
	 "crypto/tls"
 
	 "fmt"
 
	 "net/http"
 
	 "strings"
 
	 "testing"
 
	 "time"
 
	 "github.com/gruntwork-io/terratest/modules/gcp"
 
	 "github.com/gruntwork-io/terratest/modules/terraform"
 
	 test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
 
	 "github.com/stretchr/testify/assert"
 
 )
 
 // TestHelloWorldInfrastructure tests the entire infrastructure deployment
 
 func TestHelloWorldInfrastructure(t *testing.T) {
 
	 t.Parallel()
 
	 // Set the working directory to where the Terraform code is located
 
	 workingDir := "../terraform"
 
	 // Deploy the Terraform infrastructure
 
	 terraformOptions := &terraform.Options{
 
		 // The path to where our Terraform code is located
 
		 TerraformDir: workingDir,
 
		 // Variables to pass to our Terraform code using -var options
 
		 Vars: map[string]interface{}{
 
			 "environment":        "dev",
 
			 "your_name":          "tester",
 
			 "billing_account_id": "019A84-EB6FF8-7E7A66",
 
		 },
 
		 // Environment variables to set when running Terraform
 
		 EnvVars: map[string]string{
 
			 "GOOGLE_APPLICATION_CREDENTIALS": "./smt-the-dev-rsantos-i5qi-23015bd1143b.json",
 
		 },
 
	 }
 
	 // Clean up resources at the end of the test
 
	 defer terraform.Destroy(t, terraformOptions)
 
	 // Initialize and apply the Terraform code
 
	 terraform.InitAndApply(t, terraformOptions)
 
	 // Get the URL outputs from Terraform
 
	 lbURL := terraform.Output(t, terraformOptions, "load_balancer_url")
 
	 functionURL := terraform.Output(t, terraformOptions, "function_url")
 
	 // Test 1: HTTP GET to Load Balancer should return 200 with "Hello World"
 
	 t.Run("TestLoadBalancerGet", func(t *testing.T) {
 
		 // Create HTTP client with reasonable timeout
 
		 client := &http.Client{
 
			 Timeout: 10 * time.Second,
 
			 Transport: &http.Transport{
 
				 TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
 
			 },
 
		 }
 
		 // Make GET request to Load Balancer
 
		 resp, err := client.Get(lbURL)
 
		 if err != nil {
 
			 t.Fatalf("Failed to make GET request to Load Balancer: %v", err)
 
		 }
 
		 defer resp.Body.Close()
 
		 // Check status code
 
		 assert.Equal(t, 200, resp.StatusCode, "Expected status code 200 for GET request to Load Balancer")
 
		 // Read response body
 
		 buf := new(strings.Builder)
 
		 _, err = buf.ReadFrom(resp.Body)
 
		 if err != nil {
 
			 t.Fatalf("Failed to read response body: %v", err)
 
		 }
 
		 body := buf.String()
 
		 // Check response contains "Hello World"
 
		 assert.Contains(t, body, "Hello World", "Response should contain 'Hello World'")
 
	 })
 
	 // Test 2: HTTP POST to Load Balancer should return 405
 
	 t.Run("TestLoadBalancerPost", func(t *testing.T) {
 
		 // Create HTTP client
 
		 client := &http.Client{
 
			 Timeout: 10 * time.Second,
 
			 Transport: &http.Transport{
 
				 TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
 
			 },
 
		 }
 
		 // Create POST request
 
		 req, err := http.NewRequest("POST", lbURL, strings.NewReader(""))
 
		 if err != nil {
 
			 t.Fatalf("Failed to create POST request: %v", err)
 
		 }
 
		 // Make POST request
 
		 resp, err := client.Do(req)
 
		 if err != nil {
 
			 t.Fatalf("Failed to make POST request to Load Balancer: %v", err)
 
		 }
 
		 defer resp.Body.Close()
 
		 // Check status code (should be 403 Forbidden by Security Policy)
 
		 assert.Equal(t, 403, resp.StatusCode, "Expected status code 403 for POST request to Load Balancer")
 
	 })
 
	 // Test 3: Direct access to Cloud Function should return 401/403
 
	 t.Run("TestDirectFunctionAccess", func(t *testing.T) {
 
		 // Create HTTP client
 
		 client := &http.Client{
 
			 Timeout: 10 * time.Second,
 
			 Transport: &http.Transport{
 
				 TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
 
			 },
 
		 }
 
		 // Make GET request directly to Cloud Function
 
		 resp, err := client.Get(functionURL)
 
		 if err != nil {
 
			 t.Fatalf("Failed to make GET request to Cloud Function: %v", err)
 
		 }
 
		 defer resp.Body.Close()
 
		 // Check status code (should be 401 Unauthorized or 403 Forbidden)
 
		 assert.True(t, resp.StatusCode == 401 || resp.StatusCode == 403,
 
			 fmt.Sprintf("Expected status code 401 or 403 for direct access to Cloud Function, got %d", resp.StatusCode))
 
	 })
 
 } 