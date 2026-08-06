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
}



module.exports = new AppConfig;