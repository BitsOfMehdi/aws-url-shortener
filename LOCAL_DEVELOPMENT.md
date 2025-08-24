# Local Development Guide

This guide will help you set up a local development environment to work with your AWS Lambda functions and DynamoDB tables.

## Prerequisites

1. **Docker and Docker Compose** - For running LocalStack
2. **AWS CLI** - For syncing resources from AWS
3. **SAM CLI** - For local Lambda development
4. **Node.js** - For running Lambda functions
5. **jq** - For JSON processing in scripts

## Quick Start

### 1. Start LocalStack
```bash
# Start LocalStack container
npm run start:localstack

# Or manually
docker-compose up -d
```

### 2. Set up local environment
```bash
# Set environment variables
source local-env.sh

# Make scripts executable
chmod +x scripts/sync-to-local.sh
```

### 3. Sync existing AWS resources (optional)
If you want to work with your existing AWS resources locally:
```bash
# Sync Lambda functions and DynamoDB tables from AWS
npm run sync:aws
```

### 4. Install dependencies
```bash
# Install dependencies for all Lambda functions
npm run install:deps
```

### 5. Build and run locally
```bash
# Build the SAM application
npm run build:local

# Start local API Gateway
npm run deploy:local
```

## Working with LocalStack

### Check LocalStack status
```bash
curl http://localhost:4566/_localstack/health
```

### List local Lambda functions
```bash
aws lambda list-functions --endpoint-url http://localhost:4566
```

### List local DynamoDB tables
```bash
aws dynamodb list-tables --endpoint-url http://localhost:4566
```

### Test DynamoDB operations
```bash
# Create a test table
aws dynamodb create-table \
    --table-name test-table \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --endpoint-url http://localhost:4566

# Put an item
aws dynamodb put-item \
    --table-name test-table \
    --item '{"id":{"S":"test123"},"data":{"S":"test data"}}' \
    --endpoint-url http://localhost:4566
```

## Testing the URL Shortener API

Once your local API is running, you can test it:

### Create a short URL
```bash
curl -X POST http://localhost:3000/shorten \
  -H "Content-Type: application/json" \
  -d '{"originalUrl": "https://www.google.com"}'
```

### Redirect to original URL
```bash
# Replace {shortId} with the actual short ID from the previous response
curl -I http://localhost:3000/{shortId}
```

### Get URL statistics
```bash
# Replace {shortId} with the actual short ID
curl http://localhost:3000/stats/{shortId}
```

## Development Workflow

### 1. Make changes to Lambda functions
Edit the files in `lambdas/` directory.

### 2. Test locally
```bash
npm run test:local
```

### 3. Commit to GitHub
```bash
git add .
git commit -m "Your commit message"
git push origin main
```

### 4. Deploy to AWS
```bash
# Deploy to AWS (when ready)
sam build
sam deploy --guided
```

## Troubleshooting

### LocalStack not starting
```bash
# Check Docker status
docker ps

# Check LocalStack logs
docker logs localstack_main

# Restart LocalStack
docker-compose down
docker-compose up -d
```

### Lambda functions not working
```bash
# Check if dependencies are installed
npm run install:deps

# Rebuild SAM application
npm run build:local
```

### DynamoDB connection issues
```bash
# Verify LocalStack is running
curl http://localhost:4566/_localstack/health

# Check environment variables
echo $AWS_ENDPOINT_URL
```

## Environment Variables

The following environment variables are set for local development:

- `AWS_ACCESS_KEY_ID=test`
- `AWS_SECRET_ACCESS_KEY=test`
- `AWS_DEFAULT_REGION=us-east-1`
- `AWS_ENDPOINT_URL=http://localhost:4566`

## Useful Commands

```bash
# Start LocalStack
npm run start:localstack

# Stop LocalStack
npm run stop:localstack

# Clean build artifacts
npm run clean

# Install all dependencies
npm run install:deps

# Build and test locally
npm run test:local
```

## Next Steps

1. **Customize Lambda functions** - Modify the code in `lambdas/` directory
2. **Add tests** - Create test files for your Lambda functions
3. **Set up CI/CD** - Configure GitHub Actions for automated deployment
4. **Add monitoring** - Integrate with AWS CloudWatch or other monitoring tools
5. **Security** - Add authentication and authorization to your API
