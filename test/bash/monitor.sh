#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create monitoring directory
mkdir -p monitoring

# Monitoring interval in seconds
INTERVAL=60

# Function to check service health
check_health() {
    local url=$1
    local response=$(curl -s -w "\n%{http_code}" "$url")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✓ Service healthy (HTTP $http_code)${NC}"
        return 0
    else
        echo -e "${RED}✗ Service unhealthy (HTTP $http_code)${NC}"
        return 1
    fi
}

# Function to collect metrics
collect_metrics() {
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local metrics_file="monitoring/metrics_$timestamp.txt"
    
    echo "=== Metrics Report - $timestamp ===" > "$metrics_file"
    
    # Function execution metrics
    echo -e "\nFunction Execution Metrics:" >> "$metrics_file"
    gcloud monitoring time-series list \
        --filter="metric.type=\"cloudfunctions.googleapis.com/function/execution_count\"" \
        --format="value[separator=':'](metric.labels,points.value)" >> "$metrics_file"
    
    # Function latency metrics
    echo -e "\nFunction Latency Metrics:" >> "$metrics_file"
    gcloud monitoring time-series list \
        --filter="metric.type=\"cloudfunctions.googleapis.com/function/execution_times\"" \
        --format="value[separator=':'](metric.labels,points.value)" >> "$metrics_file"
    
    # Active instances
    echo -e "\nActive Instances:" >> "$metrics_file"
    gcloud monitoring time-series list \
        --filter="metric.type=\"cloudfunctions.googleapis.com/function/active_instances\"" \
        --format="value[separator=':'](metric.labels,points.value)" >> "$metrics_file"
}

# Function to collect logs
collect_logs() {
    local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local logs_file="monitoring/logs_$timestamp.txt"
    
    echo "=== Logs Report - $timestamp ===" > "$logs_file"
    
    # Collect recent logs
    gcloud logging read "resource.type=cloud_function" \
        --limit=50 \
        --format="table(timestamp,severity,textPayload)" >> "$logs_file"
}

# Function to check for errors
check_errors() {
    local error_count=$(gcloud logging read "resource.type=cloud_function AND severity>=ERROR" \
        --limit=1 \
        --format="value(severity)" | wc -l)
    
    if [ "$error_count" -gt 0 ]; then
        echo -e "${RED}⚠️ Errors detected in logs${NC}"
        return 1
    else
        echo -e "${GREEN}✓ No errors detected${NC}"
        return 0
    fi
}

# Main monitoring loop
echo -e "${YELLOW}Starting continuous monitoring...${NC}"
echo -e "Press Ctrl+C to stop\n"

while true; do
    timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    echo -e "\n${YELLOW}=== Monitoring Check - $timestamp ===${NC}"
    
    # Export URLs
    export LB_URL=$(cd ../../terraform && terraform output -raw load_balancer_url)
    export FUNCTION_URL=$(cd ../../terraform && terraform output -raw function_url)
    
    # Check service health
    echo -e "\nChecking service health..."
    check_health "$LB_URL"
    
    # Collect metrics
    echo -e "\nCollecting metrics..."
    collect_metrics
    
    # Collect logs
    echo -e "\nCollecting logs..."
    collect_logs
    
    # Check for errors
    echo -e "\nChecking for errors..."
    check_errors
    
    # Wait for next interval
    echo -e "\n${YELLOW}Waiting $INTERVAL seconds for next check...${NC}"
    sleep $INTERVAL
done 