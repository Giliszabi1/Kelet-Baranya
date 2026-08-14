const config = require("../config/database.config");
const mysql2 = require('mysql2/promise');

mysql2.createConnection({
    host: config.DB_host,
    port: config.DB_port,
    user: config.DB_user,
    password: config.DB_password,
    database: config.DB_database
    
})
module.exports = mysql2