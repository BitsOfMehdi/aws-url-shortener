const crypto = require("crypto");

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);

    if (body?.url) {
      function generateShortCode(length = 8) {
        const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
        let result = "";
        const bytes = crypto.randomBytes(length);
        for (let i = 0; i < length; i++) {
          result += chars[bytes[i] % chars.length];
        }
        return result;
      }

      const newKey = generateShortCode();

      return {
        statusCode: 200,
        body: JSON.stringify({
          slug: `${newKey}`,
        }),
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
