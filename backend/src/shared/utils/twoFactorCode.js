const crypto = require('crypto');

function generateTwoFactorCode() {
    return crypto.randomInt(100000, 1000000).toString();
}
module.exports = generateTwoFactorCode;