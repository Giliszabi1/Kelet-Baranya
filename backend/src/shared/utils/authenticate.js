const JWT = require("./jwt");

 function authenticate(req, res, next) {
    try {
        const authHeader = req.headers["authorization"];
 
        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return res.status(401).json({
                success: false,
                code: 401,
                errors: ["AUTHORIZATION_HEADER_MISSING."]
            });
        }
 
        const token = authHeader.split(" ")[1];
        const decoded = JWT.verifyAccessToken(token);
 
        req.user = {
            id: decoded.userId,
            type: decoded.role
        };
 
        next();
    } catch (err) {
        return res.status(401).json({
            success: false,
            code: 401,
            errors: ["INVALID_OR_EXPIRED_TOKEN."]
        });
    }
};
 
module.exports = authenticate;