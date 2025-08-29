const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient } = require("@aws-sdk/lib-dynamodb");

const region = process.env.AWS_REGION || "us-east-1";
const endpoint = process.env.DDB_ENDPOINT || undefined; // set for DynamoDB Local via .env

const base = { region };
if (endpoint) base.endpoint = endpoint;

const ddbClient = new DynamoDBClient(base);
const docClient = DynamoDBDocumentClient.from(ddbClient);

module.exports = {
  docClient,
  TABLE_NAME: process.env.TABLE_NAME || "UrlsTable",
  URL_INDEX_NAME: process.env.URL_INDEX_NAME || "UrlIndex",
};
