const DB_CONNECT = require("../../infrastructure/database/mysql.database");

class usersRepository {

    async register(username, email, password_hash) {
        const [answer] = await DB_CONNECT.query("call sp_user_register(?, ?, ?);", [username, password_hash, email])
        return answer[0][0];
    }

    async login(loginIdentifier) {
        const [answer] = await DB_CONNECT.query("call sp_user_login(?);", [loginIdentifier])
        return answer[0][0];
    }

    async createRefreshToken({user_id, token, user_agent, accept_language, sec_ch_ua, sec_ch_ua_mobile, sec_ch_ua_platform, expires_at}) { 
        const [answer] = await DB_CONNECT.query( `CALL sp_refresh_token_create(?, ?, ?, ?, ?, ?, ?, ?);`,
            [user_id, token, user_agent, accept_language, sec_ch_ua, sec_ch_ua_mobile, sec_ch_ua_platform, expires_at]);
        return answer;
    }
    async findRefreshToken(token) {
        const [answer] = await DB_CONNECT.query(`CALL sp_refresh_token_get(?)`, [token]);
        return answer[0][0];
    }
    
    async revokeRefreshToken(token) {
        const [answer] = await DB_CONNECT.query(`CALL sp_refresh_token_revoke(?)`, [token]);
        return answer;
    }

    async createPasswordResetToken({ user_id, token, expires_at }) {
        const [answer] = await DB_CONNECT.query(`CALL sp_password_reset_token_create(?, ?, ?);`, [user_id, token, expires_at]);
        return answer;
    }
 
    async findPasswordResetToken(token) {
        const [answer] = await DB_CONNECT.query(`CALL sp_password_reset_token_get(?)`, [token]);
        return answer[0][0];
    }
 
    async deletePasswordResetToken(token) {
        const [answer] = await DB_CONNECT.query(`CALL sp_password_reset_token_delete(?)`, [token]);
        return answer;
    }
 
    async updateUserPassword(user_id, password_hash) {
        const [answer] = await DB_CONNECT.query(`CALL sp_user_update_password(?, ?)`, [user_id, password_hash]);
        return answer;
    }
}

module.exports = new usersRepository()