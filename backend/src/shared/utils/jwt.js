const jwt = require("jsonwebtoken");

const jwtConfig = require('../../config/app.config').jwtRefreshTokenConfig();

const JWT_SECRET = jwtConfig.JWT_SECRET;
const JWT_EXPIRES_IN = jwtConfig.JWT_EXPIRES_IN || "15m";

class JWT {
    generateAccessToken(user) {
        return jwt.sign(
            {
                userId: user.id,
                role: user.type || "user"
            },
            JWT_SECRET,
            {
                expiresIn: JWT_EXPIRES_IN
            }
        );
    }

    verifyAccessToken(token) {
        return jwt.verify(token, JWT_SECRET);
    }
}

module.exports = new JWT();

