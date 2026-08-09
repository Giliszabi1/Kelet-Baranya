const authRepository  = require('./auth.repository');

const Encryption = require("../../utils/password")
class UserService {
    
    async register({username, email, password}) {
        const passwordHash = await Encryption.hash(password);
        const answer = await authRepository.register(username, email, passwordHash);
        return answer
    }

    async login({username, email, password}) {
        const loginIdentifier = username || email;
        const user = await authRepository.login(loginIdentifier);

        if(!user.password_hash){
            return {
                success: false,
                error: user
            }
        }

        const password_verification = await Encryption.verify(password, user.password_hash);

        if(password_verification){
            return {
                success: true,
                data: {
                    id: user.id,
                    username: user.username,
                    email: user.email
                }
            }
        }else{
            return{
                success: false,
                error: "a jelszó nem megfelelő."
            }
        }
        
    }
}
module.exports = UserService;