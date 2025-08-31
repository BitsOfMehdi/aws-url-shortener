# aws-url-shortener

A minimal **serverless URL shortener** built with **AWS Lambda, API Gateway (HTTP API v2), and DynamoDB**.  
Supports **short URL creation** (`POST /`) and **redirects** (`GET /{id}`) with local-first development using **SAM CLI** and **DynamoDB Local**.

## Features
- **Lambda Functions**:  
  - `urlShortenHandler` → creates short URLs with **8-char lowercase+digit slugs**  
  - `urlRedirectHandler` → redirects short URLs or returns 404  
- **DynamoDB**:  
  - Table: `UrlsTable` (PK: `id`)  
  - GSI: `UrlIndex` (HASH: `url`) for reverse lookups (idempotency)  
- **API Gateway HTTP API v2**:  
  - Routes:  
    - `POST /` → shorten URL  
    - `GET /{id}` → redirect  
  - Built-in **CORS** + **structured access logs**  
- **Local-first workflow**: DynamoDB Local in Docker, SAM CLI for build/run/test  
- **Secure IAM policies** (least privilege per function)  
- **Idempotency**: Same URL → same slug  
- **Collision handling**: Conditional writes ensure uniqueness  

## Local Development

### Prerequisites
- Node.js 18+
- Docker
- AWS SAM CLI
- AWS CLI (for DynamoDB commands)

### Quickstart
```bash
# 1. Start DynamoDB Local
npm run ddb:start

# 2. Create and seed table
npm run ddb:create
npm run ddb:seed

# 3. Build and run locally
sam build --use-container
sam local start-api --env-vars local-env.json
```

### Test
```bash
# Create short URL
curl -s -X POST http://127.0.0.1:3000/ \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com"}'

# Redirect
curl -i http://127.0.0.1:3000/abc123
```

## Deployment
```bash
sam deploy --guided
```

Outputs include:
- `HttpApiUrl` → base URL for API Gateway

---

## Project Structure
```
aws-url-shortener/
├── lambdas/
│   ├── dynamoClient.js
│   ├── lib/
│   │   ├── http.js
│   │   └── slug.js
│   ├── urlShortenHandler/
│   │   └── index.js
│   └── urlRedirectHandler/
│       └── index.js
├── infra/
│   └── dynamodb/
│       ├── urls-table.json
│       └── seed-data.json
├── scripts/
│   ├── ddb-create-local.sh
│   ├── ddb-inspect.sh
│   ├── ddb-seed-local.sh
│   ├── dynamodb-local.sh
│   ├── pull_lambda.sh
│   └── sync-to-local.sh
├── events/
│   ├── event.json
│   ├── redirect-sample.json
│   └── sample.json
├── config.example.json
├── docker-compose.yml
├── LOCAL_DEVELOPMENT.md
├── package.json
├── README.md
├── samconfig.toml
├── template-local.yaml
├── template.yaml
├── test-edge-cases.sh
└── test-slug-collision.sh
```

## Testing Matrix

### ✅ Happy Paths
- Shorten valid URL → `201 Created` + 8-char slug
- Same URL twice → `200 OK` + same slug (idempotency)
- Redirect seeded slug `/abc123` → `302 Found` + Location header

### ✅ Error Paths
- Missing `url` → `400 BadRequest`
- Invalid scheme (e.g., `ftp://`) → `400 BadRequest`
- Unknown slug → `404 NotFound`
- Malformed JSON → `400 BadRequest`

### ✅ Edge Cases
- Empty or whitespace-only URLs → `400 BadRequest`
- Very long URLs → `201 Created`
- Empty or null body → `400 BadRequest`

### ✅ CORS
- Preflight OPTIONS requests return proper CORS headers
- Cross-origin POST and GET requests succeed

## Observations
- **Performance (local):** shorten ~280–800 ms, redirect ~295–600 ms (incl. DynamoDB ops)
- **Reliability:** 100% pass rate across happy/error/edge test matrix
- **Logging:** Structured JSON logs from Lambdas + HTTP API access logs

