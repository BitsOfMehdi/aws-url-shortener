#!/bin/bash

echo "Testing Edge Cases for URL Shortener Lambda Functions"
echo "===================================================="

# Test 1: Empty URL
echo -e "\n1. Testing empty URL"
cat > events/empty-url.json << EOF
{
  "body": "{\"url\": \"\"}",
  "httpMethod": "POST",
  "path": "/",
  "headers": {
    "Content-Type": "application/json"
  },
  "requestContext": {
    "domainName": "localhost:3000"
  }
}
EOF
sam local invoke urlShortenHandler -e events/empty-url.json --env-vars local-env.json 2>/dev/null | grep -A 3 -B 3 "statusCode"

# Test 2: URL with only whitespace
echo -e "\n2. Testing URL with only whitespace"
cat > events/whitespace-url.json << EOF
{
  "body": "{\"url\": \"   \"}",
  "httpMethod": "POST",
  "path": "/",
  "headers": {
    "Content-Type": "application/json"
  },
  "requestContext": {
    "domainName": "localhost:3000"
  }
}
EOF
sam local invoke urlShortenHandler -e events/whitespace-url.json --env-vars local-env.json 2>/dev/null | grep -A 3 -B 3 "statusCode"

# Test 3: URL without protocol
echo -e "\n3. Testing URL without protocol"
cat > events/no-protocol.json << EOF
{
  "body": "{\"url\": \"example.com\"}",
  "httpMethod": "POST",
  "path": "/",
  "headers": {
    "Content-Type": "application/json"
  },
  "requestContext": {
    "domainName": "localhost:3000"
  }
}
EOF
sam local invoke urlShortenHandler -e events/no-protocol.json --env-vars local-env.json 2>/dev/null | grep -A 3 -B 3 "statusCode"

# Test 4: Very long URL
echo -e "\n4. Testing very long URL"
LONG_URL="https://example.com/$(printf 'a%.0s' {1..1000})"
cat > events/long-url.json << EOF
{
  "body": "{\"url\": \"$LONG_URL\"}",
  "httpMethod": "POST",
  "path": "/",
  "headers": {
    "Content-Type": "application/json"
  },
  "requestContext": {
    "domainName": "localhost:3000"
  }
}
EOF
sam local invoke urlShortenHandler -e events/long-url.json --env-vars local-env.json 2>/dev/null | grep -A 3 -B 3 "statusCode"

# Test 5: Empty body
echo -e "\n5. Testing empty body"
cat > events/empty-body.json << EOF
{
  "body": "",
  "httpMethod": "POST",
  "path": "/",
  "headers": {
    "Content-Type": "application/json"
  },
  "requestContext": {
    "domainName": "localhost:3000"
  }
}
EOF
sam local invoke urlShortenHandler -e events/empty-body.json --env-vars local-env.json 2>/dev/null | grep -A 3 -B 3 "statusCode"

# Test 6: Null body
echo -e "\n6. Testing null body"
cat > events/null-body.json << EOF
{
  "body": null,
  "httpMethod": "POST",
  "path": "/",
  "headers": {
    "Content-Type": "application/json"
  },
  "requestContext": {
    "domainName": "localhost:3000"
  }
}
EOF
sam local invoke urlShortenHandler -e events/null-body.json --env-vars local-env.json 2>/dev/null | grep -A 3 -B 3 "statusCode"

echo -e "\nEdge case testing completed!"
