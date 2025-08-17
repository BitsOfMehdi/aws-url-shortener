const { handler } = require("../lambdas/urlRedirectHandler/index");

// Simulated event from API Gateway
const event = {
  pathParameters: {
    id: "helo",
  },
};

handler(event).then((res) => {
  console.log(res);
});
