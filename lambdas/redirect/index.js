const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand, UpdateCommand } = require('@aws-sdk/lib-dynamodb');

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

        // Get URL from DynamoDB
        const getParams = {
            TableName: TABLE_NAME,
            Key: {
                shortId
            }
        };

        const result = await dynamodb.send(new GetCommand(getParams));

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

        const { originalUrl } = result.Item;

        // Update click count
        const updateParams = {
            TableName: TABLE_NAME,
            Key: {
                shortId
            },
            UpdateExpression: 'SET clicks = clicks + :inc',
            ExpressionAttributeValues: {
                ':inc': 1
            }
        };

        await dynamodb.send(new UpdateCommand(updateParams));

        // Redirect to original URL
        return {
            statusCode: 302,
            headers: {
                'Location': originalUrl,
                'Access-Control-Allow-Origin': '*'
            },
            body: ''
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
