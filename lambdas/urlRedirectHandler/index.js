exports.handler = async (event) => {
  const id = event.pathParameters.id; // /url/{id}

  // Dummy data
  const redirects = {
    hello: "https://example.com",
    aws: "https://aws.amazon.com",
    gh: "https://github.com",
  };

  // 301 redirect
  if (redirects[id]) {
    return {
      statusCode: 301,
      headers: {
        Location: redirects[id],
      },
    };
  }

  // 404
  return {
    statusCode: 404,
    body: JSON.stringify({ message: "Not found" }),
  };
};
