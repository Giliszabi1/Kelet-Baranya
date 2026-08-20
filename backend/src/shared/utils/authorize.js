function authozite(...allowedRoles) {
    return (req, res, next) => {
        if(!req.user){
            return res.status(401).json({
                success: false,
                code: 401,
                errors: ["UNAUTHENTICATED"]
            })
        }

        if(!allowedRoles.includes(req.user.type)){
            return res.status(403).json({
                success: false,
                code: 401,
                errors: ["FORBIDDEN."]
            })
        }
        next();
    }
}

module.exports = authozite;