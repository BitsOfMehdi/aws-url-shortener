#!/bin/bash

# Script to pull Lambda functions from AWS to local development
set -e

# Check if required parameters are provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <function_name1> <function_name2> ..."
    echo "Example: $0 urlShortenHandler urlRedirectHandler"
    exit 1
fi

# Set AWS profile and region from environment or use defaults
PROFILE=${PROFILE:-default}
REGION=${REGION:-us-east-1}

echo "🔄 Pulling Lambda functions from AWS..."
echo "Profile: $PROFILE"
echo "Region: $REGION"

# Create lambdas directory if it doesn't exist
mkdir -p lambdas

# Function to pull a Lambda function
pull_lambda_function() {
    local func_name=$1
    echo "📦 Pulling function: $func_name"
    
    # Create function directory
    mkdir -p "lambdas/$func_name"
    
    # Get function code
    aws lambda get-function \
        --function-name "$func_name" \
        --profile "$PROFILE" \
        --region "$REGION" \
        --query 'Code.Location' \
        --output text > /tmp/function_url.txt
    
    FUNCTION_URL=$(cat /tmp/function_url.txt)
    
    # Download function code
    curl -o "/tmp/${func_name}.zip" "$FUNCTION_URL"
    
    # Extract function code
    unzip -o "/tmp/${func_name}.zip" -d "lambdas/$func_name/"
    
    # Create package.json if it doesn't exist
    if [ ! -f "lambdas/$func_name/package.json" ]; then
        echo '{}' > "lambdas/$func_name/package.json"
    fi
    
    # Create package.dev.json for local development
    if [ ! -f "lambdas/$func_name/package.dev.json" ]; then
        cat > "lambdas/$func_name/package.dev.json" << EOF
{
  "name": "$func_name",
  "version": "1.0.0",
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.490.0",
    "@aws-sdk/lib-dynamodb": "^3.490.0"
  }
}
EOF
    fi
    
    echo "✅ Pulled function: $func_name"
}

# Pull each function
for func_name in "$@"; do
    pull_lambda_function "$func_name"
done

# Clean up temporary files
rm -f /tmp/function_url.txt /tmp/*.zip

echo "✅ All functions pulled successfully!"
echo ""
echo "Next steps:"
echo "1. Install dependencies: npm run install:deps"
echo "2. Build locally: sam build --use-container"
echo "3. Test locally: sam local start-api"
