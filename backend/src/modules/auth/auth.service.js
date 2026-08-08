const authRepository  = require('./auth.repository');

const Encryption = require("../../utils/password")
class UserService {
    
    async register({username, email, password}) {

        const loginIdentifier = username || email;

        const passwordHash = await Encryption.hash(password);

        const answer = await authRepository.register(username, email, passwordHash);

        return answer
    }
}
module.exports = UserService;