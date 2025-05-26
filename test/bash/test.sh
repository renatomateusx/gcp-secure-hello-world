#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create reports directory
mkdir -p reports

# Report filename
REPORT_FILE="reports/test_report_$(date +%Y%m%d_%H%M%S).md"

# Function to add content to report
add_to_report() {
    echo "$1" >> "$REPORT_FILE"
}

# Initialize report
echo "# Test Report - $(date)" > "$REPORT_FILE"
add_to_report "\n## Test Results\n"

echo -e "${YELLOW}Starting integration tests...${NC}"

# Set URLs directly
export LB_URL="http://34.98.87.137/helloWorld"
export FUNCTION_URL="https://us-central1-smt-the-dev-rsantos-i5qi.cloudfunctions.net/hello-world"

add_to_report "### Tested URLs\n"
add_to_report "- Load Balancer URL: ${LB_URL}"
add_to_report "- Cloud Function URL: ${FUNCTION_URL}\n"

# Test 1: Basic GET request
echo -e "\n${YELLOW}Test 1: Basic GET request${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" "${LB_URL}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ GET request successful${NC}"
    add_to_report "#### Test 1: GET Request\n- Status: ✅ Success (HTTP $HTTP_CODE)\n- Response: $BODY\n"
else
    echo -e "${RED}✗ GET request failed${NC}"
    add_to_report "#### Test 1: GET Request\n- Status: ❌ Failed (HTTP $HTTP_CODE)\n- Response: $BODY\n"
fi

# Test 2: POST request (should return 405)
echo -e "\n${YELLOW}Test 2: POST request${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${LB_URL}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 405 ]; then
    echo -e "${GREEN}✓ POST request correctly rejected${NC}"
    add_to_report "#### Test 2: POST Request\n- Status: ✅ Success (HTTP $HTTP_CODE - Method Not Allowed)\n"
else
    echo -e "${RED}✗ POST request not properly handled${NC}"
    add_to_report "#### Test 2: POST Request\n- Status: ❌ Failed (HTTP $HTTP_CODE)\n"
fi

# Test 3: Direct Cloud Function access (should return 401/403)
echo -e "\n${YELLOW}Test 3: Direct Cloud Function access${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" "${FUNCTION_URL}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [[ "$HTTP_CODE" -eq 401 || "$HTTP_CODE" -eq 403 ]]; then
    echo -e "${GREEN}✓ Direct function access correctly blocked${NC}"
    add_to_report "#### Test 3: Direct Function Access\n- Status: ✅ Success (HTTP $HTTP_CODE - Access Denied)\n"
else
    echo -e "${RED}✗ Direct function access not properly secured${NC}"
    add_to_report "#### Test 3: Direct Function Access\n- Status: ❌ Failed (HTTP $HTTP_CODE)\n"
fi

# Test 4: Rate Limiting
echo -e "\n${YELLOW}Test 4: Rate Limiting${NC}"
add_to_report "#### Test 4: Rate Limiting\n"
for i in {1..5}; do
    echo "Request $i"
    RESPONSE=$(curl -s -w "\n%{http_code}" "${LB_URL}")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    add_to_report "- Request $i: HTTP $HTTP_CODE\n"
    sleep 1
done

# Test 5: XSS Attack Simulation
echo -e "\n${YELLOW}Test 5: XSS Attack Simulation${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" "${LB_URL}?param=<script>alert('xss')</script>")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 403 ]; then
    echo -e "${GREEN}✓ XSS attack correctly blocked${NC}"
    add_to_report "#### Test 5: XSS Attack\n- Status: ✅ Success (HTTP $HTTP_CODE - Blocked)\n"
else
    echo -e "${RED}✗ XSS attack not properly handled${NC}"
    add_to_report "#### Test 5: XSS Attack\n- Status: ❌ Failed (HTTP $HTTP_CODE)\n"
fi

# Test 6: SQL Injection Simulation
echo -e "\n${YELLOW}Test 6: SQL Injection Simulation${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" "${LB_URL}?param=1' OR '1'='1")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 403 ]; then
    echo -e "${GREEN}✓ SQL Injection correctly blocked${NC}"
    add_to_report "#### Test 6: SQL Injection\n- Status: ✅ Success (HTTP $HTTP_CODE - Blocked)\n"
else
    echo -e "${RED}✗ SQL Injection not properly handled${NC}"
    add_to_report "#### Test 6: SQL Injection\n- Status: ❌ Failed (HTTP $HTTP_CODE)\n"
fi

# Collect Cloud Monitoring metrics
echo -e "\n${YELLOW}Collecting Cloud Monitoring metrics...${NC}"
add_to_report "\n## Cloud Monitoring Metrics\n"

# Function to collect metrics
collect_metrics() {
    METRIC_NAME=$1
    METRIC_DATA=$(gcloud monitoring time-series list \
        --filter="metric.type=\"$METRIC_NAME\"" \
        --format="value[separator=':'](metric.labels,points.value)" \
        2>/dev/null)
    
    if [ ! -z "$METRIC_DATA" ]; then
        add_to_report "### $METRIC_NAME\n\`\`\`\n$METRIC_DATA\n\`\`\`\n"
    fi
}

# Collect important metrics
collect_metrics "cloudfunctions.googleapis.com/function/execution_count"
collect_metrics "cloudfunctions.googleapis.com/function/execution_times"
collect_metrics "cloudfunctions.googleapis.com/function/active_instances"

# Collect Cloud Logging logs
echo -e "\n${YELLOW}Collecting Cloud Logging logs...${NC}"
add_to_report "\n## Cloud Logging Logs\n"

LOGS=$(gcloud logging read "resource.type=cloud_function" --limit=10 --format="table(timestamp,severity,textPayload)" 2>/dev/null)
if [ ! -z "$LOGS" ]; then
    add_to_report "\`\`\`\n$LOGS\n\`\`\`\n"
fi

# Convert report to PDF
echo -e "\n${YELLOW}Converting report to PDF...${NC}"
if command -v pandoc &> /dev/null; then
    pandoc "$REPORT_FILE" -o "${REPORT_FILE%.md}.pdf"
    echo -e "${GREEN}PDF report generated: ${REPORT_FILE%.md}.pdf${NC}"
else
    echo -e "${RED}Pandoc not found. Install to generate PDF.${NC}"
    echo "To install: brew install pandoc"
fi

echo -e "\n${GREEN}Tests completed! Report generated at: $REPORT_FILE${NC}" 