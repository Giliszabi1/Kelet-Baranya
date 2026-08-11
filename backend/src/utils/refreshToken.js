const crypto = require("crypto");

class RefreshToken {
    generate() {
        return crypto.randomBytes(64).toString("hex");
    }
}

module.exports = new RefreshToken();
