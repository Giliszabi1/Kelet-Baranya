require('dotenv').config();

const appConfig={
    PORT: process.env.SERVER_PORT,
    HOST: process.env.SERVER_HOST
}
module.exports = appConfig;
