#!/bin/bash

# Script to sync existing AWS resources to LocalStack
set -e

# Source local environment
source ../local-env.sh

echo "🔄 Syncing AWS resources to LocalStack..."

# Check if LocalStack is running
if ! curl -s http://localhost:4566/_localstack/health > /dev/null; then
    echo "❌ LocalStack is not running. Please start it first with: docker-compose up -d"
    exit 1
fi

echo "✅ LocalStack is running"

# Function to sync Lambda functions
sync_lambda_functions() {
    echo "📦 Syncing Lambda functions..."
    
    # Get list of Lambda functions from AWS
    FUNCTIONS=$(aws lambda list-functions --query 'Functions[*].FunctionName' --output text)
    
    for func_name in $FUNCTIONS; do
        echo "Processing function: $func_name"
        
        # Get function code
        aws lambda get-function --function-name "$func_name" --query 'Code.Location' --output text > /tmp/function_url.txt
        FUNCTION_URL=$(cat /tmp/function_url.txt)
        
        # Download function code
        curl -o "/tmp/${func_name}.zip" "$FUNCTION_URL"
        
        # Create function in LocalStack
        aws lambda create-function \
            --function-name "$func_name" \
            --runtime nodejs20.x \
            --role arn:aws:iam::000000000000:role/lambda-role \
            --handler index.handler \
            --zip-file "fileb:///tmp/${func_name}.zip" \
            --endpoint-url http://localhost:4566
        
        echo "✅ Synced function: $func_name"
    done
}

# Function to sync DynamoDB tables
sync_dynamodb_tables() {
    echo "🗄️ Syncing DynamoDB tables..."
    
    # Get list of DynamoDB tables from AWS
    TABLES=$(aws dynamodb list-tables --query 'TableNames' --output text)
    
    for table_name in $TABLES; do
        echo "Processing table: $table_name"
        
        # Get table description
        TABLE_DESC=$(aws dynamodb describe-table --table-name "$table_name")
        
        # Extract table schema
        TABLE_SCHEMA=$(echo "$TABLE_DESC" | jq -r '.Table')
        
        # Create table in LocalStack
        aws dynamodb create-table \
            --cli-input-json "$TABLE_SCHEMA" \
            --endpoint-url http://localhost:4566
        
        echo "✅ Synced table: $table_name"
    done
}

# Main execution
echo "🚀 Starting sync process..."

# Sync Lambda functions
sync_lambda_functions

# Sync DynamoDB tables
sync_dynamodb_tables

echo "✅ Sync completed successfully!"
echo ""
echo "You can now work with your resources locally:"
echo "- Lambda functions: aws lambda list-functions --endpoint-url http://localhost:4566"
echo "- DynamoDB tables: aws dynamodb list-tables --endpoint-url http://localhost:4566"
