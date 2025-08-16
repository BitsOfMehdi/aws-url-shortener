const { handler } = require("../lambdas/helloWorld/index");

// Mock event like API Gateway or custom trigger
const event = { name: "Mehdi" };

handler(event)
  .then((res) => {
    console.log("Lambda Response:", res);
  })
  .catch((err) => {
    console.error("Lambda Error:", err);
  });
