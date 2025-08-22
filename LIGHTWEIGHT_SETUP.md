# Lightweight Lambda Functions Setup

## Overview

This setup provides the most lightweight Lambda functions possible while maintaining full functionality for both local development and AWS deployment.

## Key Optimizations

### 1. **Zero Dependencies for Production**
- `package.json` files are empty (`{}`) for production deployment
- Uses AWS SDK v3 that's available in Lambda runtime
- Uses `crypto` (built-in Node.js module)

### 2. **Development vs Production**

#### For Local Development (LocalStack)
```bash
# Install dependencies for local testing
npm run install:deps
```

#### For AWS Deployment
```bash
# Prepare for production (removes dependencies)
npm run install:prod
```

### 3. **Environment-Aware Configuration**
- Functions automatically detect local vs production environment
- Uses `AWS_ENDPOINT_URL` for LocalStack
- Uses default AWS endpoints for production

## File Structure

```
lambdas/
├── createShortUrl/
│   ├── index.js              # Production code (no dependencies)
│   ├── package.json          # Empty for production
│   └── package.dev.json      # Dependencies for local development
├── redirect/
│   ├── index.js              # Production code (no dependencies)
│   ├── package.json          # Empty for production
│   └── package.dev.json      # Dependencies for local development
└── getStats/
    ├── index.js              # Production code (no dependencies)
    ├── package.json          # Empty for production
    └── package.dev.json      # Dependencies for local development
```

## Deployment Sizes

### Production Deployment
- **Total size**: ~5-10KB per function
- **Dependencies**: 0 (uses AWS runtime)
- **Cold start**: Fastest possible

### Local Development
- **Total size**: ~50-100KB per function
- **Dependencies**: AWS SDK v3 modules
- **Cold start**: Slightly slower due to dependencies

## Workflow

### 1. Local Development
```bash
# Start LocalStack
npm run start:localstack

# Install dependencies for local testing
npm run install:deps

# Test locally
npm run test:local
```

### 2. Production Deployment
```bash
# Prepare for production (removes dependencies)
npm run install:prod

# Deploy to AWS
sam build
sam deploy --guided
```

## Benefits

1. **Minimal Deployment Size**: Functions are as small as possible
2. **Fast Cold Starts**: No dependency loading in production
3. **Cost Effective**: Smaller packages = faster deployments
4. **Maintainable**: Same code works in both environments
5. **Future Proof**: Uses latest AWS SDK v3

## Dependencies Used

### Production (AWS Runtime)
- `crypto` - Built-in Node.js module
- `@aws-sdk/client-dynamodb` - Available in Lambda runtime
- `@aws-sdk/lib-dynamodb` - Available in Lambda runtime

### Local Development (LocalStack)
- `@aws-sdk/client-dynamodb` - Explicitly installed
- `@aws-sdk/lib-dynamodb` - Explicitly installed

## Notes

- AWS Lambda runtime includes AWS SDK v3 by default
- No need to bundle AWS SDK for production deployments
- LocalStack requires explicit installation of dependencies
- The setup automatically handles both environments
