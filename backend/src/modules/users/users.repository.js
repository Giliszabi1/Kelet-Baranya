const DB_CONNECT = require("../../infrastructure/database/mysql.database");

class usersRepository {

    async register(username, email, password_hash) {
        const [answer] = await DB_CONNECT.query("call sp_user_create(?, ?, ?);", [username, password_hash, email])
        console.log(answer)
        return answer;
    }
}

module.exports = new usersRepository()