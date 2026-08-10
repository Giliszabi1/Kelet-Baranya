const DB_CONNECT = require("../../database/mysql.database");

class usersRepository {

    async register(username, email, password_hash) {
        const [answer] = await DB_CONNECT.query("call sp_user_register(?, ?, ?);", [username, password_hash, email])
        return answer[0][0];
    }

    async login(loginIdentifier) {
        const [answer] = await DB_CONNECT.query("call sp_user_login(?);", [loginIdentifier])
        return answer[0][0];
    }
}

module.exports = new usersRepository()