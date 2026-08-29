const DB_CONNECT = require("../../../infrastructure/database/mysql.database");

class OrganizerRepository {

    async register(username, email, password_hash, fullname) {
        const [answer] = await DB_CONNECT.query("call sp_organizer_register(?, ?, ?, ?, ?);", [username, password_hash, email, fullname, 1])
        return answer[0][0];
    }

    async login(loginIdentifier) {
        const [answer] = await DB_CONNECT.query("call sp_user_login(?, ?);", [loginIdentifier, "organizer"])
        return answer[0][0];
    }

    async createRefreshToken({user_id, token, user_agent, accept_language, sec_ch_ua, sec_ch_ua_mobile, sec_ch_ua_platform, expires_at}) { 
        const [answer] = await DB_CONNECT.query( `CALL sp_refresh_token_create(?, ?, ?, ?, ?, ?, ?, ?);`,
            [user_id, token, user_agent, accept_language, sec_ch_ua, sec_ch_ua_mobile, sec_ch_ua_platform, expires_at]);
        return answer;
    }
    async findRefreshTokenOrganizer(token) {
        const [answer] = await DB_CONNECT.query(`CALL sp_refresh_token_get(?, ?)`, [token, "organizer"]);
        return answer[0][0];
    }
    async findOrganizerById(userId) {
        const [answer] = await DB_CONNECT.query(`CALL sp_organizer_get_by_id(?, ?)`, [userId, "organizer"]);
        return answer[0][0];
    }
    
    async revokeRefreshToken(token) {
        const [answer] = await DB_CONNECT.query(`CALL sp_refresh_token_revoke(?, ?)`, [token, "organizer"]);
        return answer;
    }

    async createToken({ user_id, token, type, expires_at }) {
        const [answer] = await DB_CONNECT.query(`CALL sp_user_token_create(?, ?, ?, ?);`, [user_id, token, type, expires_at]);
        return answer;
    }
 
    async findToken(token) {
        const [answer] = await DB_CONNECT.query(`CALL sp_user_token_get(?, ?)`, [token, "organizer"]);
        return answer[0][0];
    }
 
    async deleteToken(token) {
        const [answer] = await DB_CONNECT.query(`CALL sp_user_token_delete(?, ?)`, [token, "organizer"]);
        return answer;
    }
 
    async updateUserPassword(user_id, password_hash) {
        const [answer] = await DB_CONNECT.query(`CALL sp_user_update_password(?, ?, ?)`, [user_id, password_hash, "organizer"]);
        return answer;
    }

    async confirmEmail(user_id) {
        const [answer] = await DB_CONNECT.query(`CALL sp_user_confirm_email(?, ?)`, [user_id, "organizer"]);
        return answer;
    }

}

module.exports = new OrganizerRepository()