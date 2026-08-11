const jwtConfig = require('../../config/app.config').jwtRefreshTokenConfig();

const authRepository  = require('./auth.user.repository');

const Encryption = require("../../utils/password")
const JWT = require("../../utils/jwt");
const RefreshToken = require('../../utils/refreshToken');
class UserService {
    

    async register({username, email, password, client}) {

        const passwordHash = await Encryption.hash(password);

        const user = await authRepository.register(username, email, passwordHash);

        const accessToken = JWT.generateAccessToken({ id: user.id, type: user.type || "user" }); 
        const refreshToken = RefreshToken.generate(); 

        const expiresAt = new Date(); 
        expiresAt.setDate(expiresAt.getDate() + Number(jwtConfig.REFRESH_TOKEN_EXPIRES_DAYS || 30)); 

        await authRepository.createRefreshToken({   
            user_id: user.id,
            token: refreshToken, 
            user_agent: client.user_agent, 
            accept_language: client.accept_language, 
            sec_ch_ua: client.sec_ch_ua, 
            sec_ch_ua_mobile: client.sec_ch_ua_mobile, 
            sec_ch_ua_platform: client.sec_ch_ua_platform, 
            expires_at: expiresAt
        }); 

        return { 
            id: user.id, 
            username: user.username, 
            email: user.email, 
            accessToken, 
            refreshToken 
        };
    }

    async login({username, email, password, client}) {
        const loginIdentifier = username || email;
        const user = await authRepository.login(loginIdentifier);

        if(!user.password_hash){
            return {
                success: false,
                error: user
            }
        }

        const password_verification = await Encryption.verify(password, user.password_hash);
        if(!password_verification){
            return{
                success: false,
                error: "a jelszó nem megfelelő."
            }
        }

        const accessToken = JWT.generateAccessToken({
            id: user.id,
            type: user.type || "user"
        });

        const refreshToken = RefreshToken.generate();

        const expiresAt = new Date();
        expiresAt.setDate( expiresAt.getDate() + Number(jwtConfig.REFRESH_TOKEN_EXPIRES_DAYS || 30) );

        await authRepository.createRefreshToken({ 
            user_id: user.id,
            token: refreshToken,
            user_agent: client.user_agent,
            accept_language: client.accept_language,
            sec_ch_ua: client.sec_ch_ua,
            sec_ch_ua_mobile: client.sec_ch_ua_mobile,
            sec_ch_ua_platform: client.sec_ch_ua_platform,
            expires_at: expiresAt
        });

        if(password_verification){
            return {
                success: true,
                data: {
                    id: user.id,
                    username: user.username,
                    email: user.email,
                    accessToken: accessToken,
                    refreshToken: refreshToken
                }
            }
        }
    }

    async refresh({ token, client }) {
        const refreshToken = await authRepository.findRefreshToken(token);

        if (!refreshToken) {
            return {
                success: false,
                error: "Érvénytelen refresh token."
            };
        }

        if (refreshToken.revoked_at) {
            return {
                success: false,
                error: "A refresh token vissza lett vonva."
            };
        }

        const now = new Date();
        const expiresAt = new Date(refreshToken.expires_at);

        if (expiresAt <= now) {

            await authRepository.revokeRefreshToken(token);

            return {
                success: false,
                error: "A refresh token lejárt."
            };
        }

        const accessToken = JWT.generateAccessToken({
            id: refreshToken.user_id,
            type: refreshToken.type || "user"
        });

        await authRepository.revokeRefreshToken(token);

        const newRefreshToken = RefreshToken.generate();

        const newExpiresAt = new Date();
        newExpiresAt.setDate(newExpiresAt.getDate() + Number(process.env.REFRESH_TOKEN_EXPIRES_DAYS || 30));


        await authRepository.createRefreshToken({

            user_id: refreshToken.user_id,

            token: newRefreshToken,

            user_agent: client.user_agent,
            accept_language: client.accept_language,
            sec_ch_ua: client.sec_ch_ua,
            sec_ch_ua_mobile: client.sec_ch_ua_mobile,
            sec_ch_ua_platform: client.sec_ch_ua_platform,

            expires_at: newExpiresAt
        });


        return {
            success: true,

            data: {
                accessToken,
                refreshToken: newRefreshToken
            }
        };
    }

    async logout(token) {

        const refreshToken = await authRepository.findRefreshToken(token);
        
        if (!refreshToken) {
            return {
                success: false,
                error: "Érvénytelen refresh token."
            };
        }

        await authRepository.revokeRefreshToken(token);
    
        return {
            success: true
        };
    }
}
module.exports = UserService;