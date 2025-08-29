const { QueryCommand, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { docClient, TABLE_NAME, URL_INDEX_NAME } = require("../dynamoClient");
const { json, badRequest, internal } = require("../lib/http");
const { newSlug } = require("../lib/slug");

const isValidUrl = (value) => {
  try {
    const u = new URL(value);
    return u.protocol === "http:" || u.protocol === "https:";
  } catch {
    return false;
  }
};

exports.handler = async (event) => {
  const start = Date.now();
  try {
    let body = {};
    if (event && event.body) {
      try { body = typeof event.body === "string" ? JSON.parse(event.body) : event.body; }
      catch { return badRequest("invalid JSON body"); }
    }
    const url = body.url;
    if (!url || !isValidUrl(url)) return badRequest("url is required and must start with http(s)://");

    // 1) Reverse-lookup by URL (UrlIndex) for idempotency
    const q = await docClient.send(new QueryCommand({
      TableName: TABLE_NAME,
      IndexName: URL_INDEX_NAME,
      KeyConditionExpression: "#u = :url",
      ExpressionAttributeNames: { "#u": "url" },
      ExpressionAttributeValues: { ":url": url },
      ProjectionExpression: "id",
      Limit: 1,
    }));
    if (q.Items && q.Items.length > 0) {
      const slug = q.Items[0].id;
      console.log(JSON.stringify({ level: "info", msg: "shorten.exists", slug, t: Date.now() - start }));
      return json(200, { slug });
    }

    // 2) Allocate slug with conditional Put
    const now = new Date().toISOString();
    const MAX_TRIES = 5;
    for (let attempt = 1; attempt <= MAX_TRIES; attempt++) {
      const slug = newSlug(8);
      try {
        await docClient.send(new PutCommand({
          TableName: TABLE_NAME,
          Item: { id: slug, url, createdAt: now },
          ConditionExpression: "attribute_not_exists(#id)",
          ExpressionAttributeNames: { "#id": "id" },
        }));
        console.log(JSON.stringify({ level: "info", msg: "shorten.created", slug, attempt, t: Date.now() - start }));
        return json(201, { slug });
      } catch (err) {
        if (err && err.name === "ConditionalCheckFailedException") {
          console.warn(JSON.stringify({ level: "warn", msg: "slug.collision", attempt, slug }));
          continue; // retry new slug
        }
        console.error(JSON.stringify({ level: "error", msg: "shorten.put.error", error: String(err) }));
        return internal();
      }
    }

    console.error(JSON.stringify({ level: "error", msg: "slug.exhausted" }));
    return json(500, { error: "InternalError", message: "could not allocate slug, try again" });
  } catch (err) {
    console.error(JSON.stringify({ level: "error", msg: "shorten.error", error: String(err) }));
    return internal();
  }
};
