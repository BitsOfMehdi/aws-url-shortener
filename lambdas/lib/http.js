const headers = { "Content-Type": "application/json" };

const json = (statusCode, obj) => ({
  statusCode,
  headers,
  body: JSON.stringify(obj),
});

const redirect = (statusCode, location) => ({
  statusCode,
  headers: { Location: location },
  body: "",
});

const badRequest = (message) => json(400, { error: "BadRequest", message });
const notFound = (message) => json(404, { error: "NotFound", message });
const internal = () => json(500, { error: "InternalError", message: "unexpected error" });

module.exports = { json, redirect, badRequest, notFound, internal };
