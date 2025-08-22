const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand } = require('@aws-sdk/lib-dynamodb');

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
        const { shortId } = event.pathParameters;

        if (!shortId) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    error: 'shortId is required'
                })
            };
        }

        // Get URL stats from DynamoDB
        const params = {
            TableName: TABLE_NAME,
            Key: {
                shortId
            }
        };

        const result = await dynamodb.send(new GetCommand(params));

        if (!result.Item) {
            return {
                statusCode: 404,
                headers: {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                body: JSON.stringify({
                    error: 'Short URL not found'
                })
            };
        }

        const { originalUrl, createdAt, clicks } = result.Item;

        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                shortId,
                originalUrl,
                createdAt,
                clicks: clicks || 0
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
