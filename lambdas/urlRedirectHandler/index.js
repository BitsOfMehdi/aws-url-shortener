const { GetCommand } = require("@aws-sdk/lib-dynamodb");
const { docClient, TABLE_NAME } = require("../dynamoClient");
const { redirect, notFound, badRequest, internal } = require("../lib/http");

exports.handler = async (event) => {
  const start = Date.now();
  try {
    const id = event?.pathParameters?.id;
    if (!id) return badRequest("id path parameter is required");

    const res = await docClient.send(new GetCommand({
      TableName: TABLE_NAME,
      Key: { id },
    }));

    if (!res.Item) {
      console.log(JSON.stringify({ level: "info", msg: "redirect.miss", id, t: Date.now() - start }));
      return notFound("slug not found");
    }

    const url = res.Item.url;
    console.log(JSON.stringify({ level: "info", msg: "redirect.hit", id, t: Date.now() - start }));
    return redirect(302, url);
  } catch (err) {
    console.error(JSON.stringify({ level: "error", msg: "redirect.error", error: String(err) }));
    return internal();
  }
};
  