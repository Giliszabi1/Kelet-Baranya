require('dotenv').config();

class AppConfig {
    constructor() {
        
    }
    serverConfig() {
        const appConfig={
            PORT: process.env.SERVER_PORT,
            HOST: process.env.SERVER_HOST
        }
        return appConfig;
    }

    corsOptions() {
        const corsOption = {
            origin: "http://localhost:5500",
            methods: ["GET", "POST"],
        }     
        return corsOption;
    }

    globalRateLimitOption() {
        const globalRateLimitConfig = {
            windowMs: 15 * 60 * 1000, // 15 perc
            limit: 100, // max 100 request / IP / ablak

            message: {
              error: "Too many requests, please try again later."
            },

            handler: (req, res, next, options) => {
              res.status(options.statusCode).json(options.message);
            }
        }
        return globalRateLimitConfig;
    }
    jwtRefreshTokenConfig() {
        const jwtConfig={
            JWT_SECRET: process.env.JWT_SECRET,
            JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN,
            REFRESH_TOKEN_EXPIRES_DAYS: process.env.REFRESH_TOKEN_EXPIRES_DAYS
        }
        return jwtConfig;
    }
}



module.exports = new AppConfig;