const { handler } = require("../lambdas/urlShortenHandler/index");

// fake API Gateway event
const event = {
  resource: "/shorten",
  path: "/shorten",
  httpMethod: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ url: "https://example.com" }),
  isBase64Encoded: false,
};

(async () => {
  const result = await handler(event);
  console.log("Lambda result:", result);
})();
