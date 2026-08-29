const logRepository  = require('./log.repository');

class logService {
    static async create({ actor_id, actor_role, action, status, description,entity_type, entity_id, old_data, new_data, ip_address }) {
        try {
            const log = await logRepository.create({
                actor_id, 
                actor_role, 
                action,
                status,
                description,
                entity_type, 
                entity_id, 
                old_data, 
                new_data, 
                ip_address
            });

        } catch (err) {
            console.log("error: "+err)
        }
    }
}
module.exports = logService
