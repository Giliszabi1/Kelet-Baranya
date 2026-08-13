const usersRepository  = require('./users.repository');

const Encryption = require("../../shared/utils/password")
class UserService {
    
    async register({username, email, password}) {

        const passwordHash = await Encryption.hash(password);

        const answer = await usersRepository.register(username, email, passwordHash);

        return answer
    }
}
module.exports = UserService;