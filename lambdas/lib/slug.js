const crypto = require("crypto");

// Digits + lowercase only (36 chars)
const ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz";

const toBaseN = (buf) => {
  const base = BigInt(ALPHABET.length); // 36
  const bigint = BigInt("0x" + buf.toString("hex"));
  if (bigint === 0n) return ALPHABET[0];
  let n = bigint;
  let out = "";
  while (n > 0n) {
    const rem = n % base;
    out = ALPHABET[Number(rem)] + out;
    n = n / base;
  }
  return out;
};

// Always return 8 chars
const newSlug = (len = 8) => toBaseN(crypto.randomBytes(8)).slice(0, len);

module.exports = { newSlug, ALPHABET };
