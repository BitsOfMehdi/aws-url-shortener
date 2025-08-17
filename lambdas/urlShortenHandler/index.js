exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);

    if (body?.url) {
      return {
        statusCode: 200,
        body: JSON.stringify({ message: `Input value is ${body.url}` }),
      };
    } else {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Missing 'url' in request body" }),
      };
    }
  } catch (err) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Invalid JSON" }),
    };
  }
};
