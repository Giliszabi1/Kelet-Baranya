const serverConfig = require("../../config/app.config")

const apiUrl = `http://localhost:${serverConfig.serverConfig().PORT}/api`;
console.log(apiUrl)
module.exports = apiUrl;