#!/bin/bash

# Output colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting tests...${NC}"

# Export URLs
export LB_URL="http://34.98.87.137/helloWorld"
export FUNCTION_URL="https://us-central1-smt-the-dev-rsantos-i5qi.cloudfunctions.net/hello-world"

echo -e "${GREEN}Load Balancer URL: ${LB_URL}${NC}"
echo -e "${GREEN}Cloud Function URL: ${FUNCTION_URL}${NC}"

# Test 1: GET request
echo -e "\n${YELLOW}Test 1: GET request${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${LB_URL}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ GET request successful${NC}"
else
    echo -e "${RED}✗ GET request failed (HTTP $HTTP_CODE)${NC}"
fi

echo -e "Response: $BODY\n"

# Test 2: POST request (should return 405 or 403)
echo -e "\n${YELLOW}Test 2: POST request${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST -d '{"msg":"test"}' -H "Content-Type: application/json" "${LB_URL}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
if [ "$HTTP_CODE" -eq 405 ] || [ "$HTTP_CODE" -eq 403 ]; then
    echo -e "${GREEN}✓ POST request correctly rejected (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}✗ POST request not properly handled (HTTP $HTTP_CODE)${NC}"
fi

echo -e "Response: $(echo "$RESPONSE" | sed '$d')\n"

# Test 3: Direct Cloud Function access (should return 401/403)
echo -e "\n${YELLOW}Test 3: Direct Cloud Function access${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${FUNCTION_URL}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
if [ "$HTTP_CODE" -eq 401 ] || [ "$HTTP_CODE" -eq 403 ]; then
    echo -e "${GREEN}✓ Direct function access correctly blocked (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}✗ Direct function access not properly secured (HTTP $HTTP_CODE)${NC}"
fi

echo -e "Response: $(echo "$RESPONSE" | sed '$d')\n"

# Test 4: Rate Limiting
echo -e "\n${YELLOW}Test 4: Rate Limiting${NC}"
for i in {1..5}; do
    echo "Request $i"
    RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${LB_URL}")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    echo "HTTP $HTTP_CODE"
    sleep 1
done

echo -e "\n"

# Test 5: XSS Attack
echo -e "\n${YELLOW}Test 5: XSS Attack${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${LB_URL}?param=<script>alert('xss')</script>")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
if [ "$HTTP_CODE" -eq 403 ]; then
    echo -e "${GREEN}✓ XSS attack correctly blocked (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}✗ XSS attack not properly handled (HTTP $HTTP_CODE)${NC}"
fi

echo -e "Response: $(echo "$RESPONSE" | sed '$d')\n"

# Test 6: SQL Injection
echo -e "\n${YELLOW}Test 6: SQL Injection${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${LB_URL}?param=1' OR '1'='1")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
if [ "$HTTP_CODE" -eq 403 ]; then
    echo -e "${GREEN}✓ SQL Injection correctly blocked (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}✗ SQL Injection not properly handled (HTTP $HTTP_CODE)${NC}"
fi

echo -e "Response: $(echo "$RESPONSE" | sed '$d')\n"

echo -e "${GREEN}All tests have been executed!${NC}"