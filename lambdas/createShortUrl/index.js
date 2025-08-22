const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');
const crypto = require('crypto');

// Use AWS SDK v3 that's available in Lambda runtime
const clientConfig = {
    region: process.env.AWS_DEFAULT_REGION || 'us-east-1'
};

// Add endpoint for local development (LocalStack)
if (process.env.AWS_ENDPOINT_URL) {
    clientConfig.endpoint = process.env.AWS_ENDPOINT_URL;
}

const client = new DynamoDBClient(clientConfig);
const dynamodb = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.DYNAMODB_TABLE;

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body);
        const { originalUrl } = body;

        if (!originalUrl) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    error: 'originalUrl is required'
                })
            };
        }

        // Generate short ID (8 characters for better uniqueness)
        const shortId = crypto.randomBytes(4).toString('hex');
        
        // Create timestamp
        const timestamp = new Date().toISOString();

        // Store in DynamoDB
        const params = {
            TableName: TABLE_NAME,
            Item: {
                shortId,
                originalUrl,
                createdAt: timestamp,
                clicks: 0
            }
        };

        await dynamodb.send(new PutCommand(params));

        // Construct short URL
        const shortUrl = `${event.requestContext.domainName}/${shortId}`;

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                shortId,
                originalUrl,
                shortUrl,
                createdAt: timestamp
            })
        };

    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                error: 'Internal server error'
            })
        };
    }
};
