const DB_CONNECT = require("../../infrastructure/database/mysql.database");
class logRepository {
    async create({actor_id, actor_role, action, status, description, entity_type, entity_id, old_data, new_data, ip_address}) {
        DB_CONNECT.query("call sp_create_audit_log(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
            [actor_id, actor_role, action, status, description, entity_type, entity_id, old_data, new_data, ip_address])
    }
}

module.exports = new logRepository();
