#!/bin/bash

echo "Testing Slug Collision Handling"
echo "==============================="

# Test 1: Create multiple URLs rapidly to test collision handling
echo -e "\n1. Testing rapid URL creation (potential collisions)"
for i in {1..10}; do
  echo "Creating URL $i..."
  cat > events/rapid-url-$i.json << EOF
{
  "body": "{\"url\": \"https://test$i.example.com\"}",
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
  sam local invoke urlShortenHandler -e events/rapid-url-$i.json --env-vars local-env.json 2>/dev/null | grep -A 1 -B 1 "statusCode"
done

# Test 2: Test idempotency with same URL multiple times
echo -e "\n2. Testing idempotency (same URL multiple times)"
for i in {1..3}; do
  echo "Call $i with same URL..."
  sam local invoke urlShortenHandler -e events/rapid-url-1.json --env-vars local-env.json 2>/dev/null | grep -A 1 -B 1 "statusCode"
done

echo -e "\nSlug collision testing completed!"
