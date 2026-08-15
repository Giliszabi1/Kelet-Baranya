const crypto = require("crypto");

class Token {
    generate() {
        return crypto.randomBytes(64).toString("hex");
    }
}

module.exports = new Token();
