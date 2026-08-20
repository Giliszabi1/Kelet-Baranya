const jwtConfig = require('../../config/app.config').jwtRefreshTokenConfig();
const twoFactoryCodeConfig = require('../../config/app.config').twoFactoryCodeConfig();

const authRepository  = require('./auth.user.repository');

const Encryption = require("../../shared/utils/password")
const JWT = require("../../shared/utils/jwt");
const Token = require('../../shared/utils/token');

const authUserEmailService = require('./auth.user.email.service');

const generateTwoFactorCode = require("../../shared/utils/twoFactorCode")
 

class UserService {
    

    async register({username, email, password, client}) {

        const passwordHash = await Encryption.hash(password);

        const user = await authRepository.register(username, email, passwordHash);

        const accessToken = JWT.generateAccessToken({ id: user.id, type: user.type || "user" });
        const refreshToken = Token.generate(); 

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

        const newRegistrationToken = Token.generate();

        const registrationExpiresAt = new Date(Date.now() + 10 * 60 * 1000)

        const registrationToken = await authRepository.createToken({
            user_id: user.id, 
            token: newRegistrationToken, 
            type: "register",
            expires_at: registrationExpiresAt
        });

        await authUserEmailService.register({
            username: username, 
            email: email, 
            token: newRegistrationToken
        })

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

        if (user.two_factor_enabled) {
            const code = await this.issueTwoFactorCode(user);
 
            await authUserEmailService.sendTwoFactorCode({
                username: user.username,
                email: user.email,
                code: code
            });
 
            return {
                success: true,
                requires2FA: true,
                data: {
                    message: "2FA_REQUIRED"
                }
            };
        }

        const accessToken = JWT.generateAccessToken({
            id: user.id,
            type: user.type || "user"
        });

        const refreshToken = Token.generate();

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

        const newRefreshToken = Token.generate();

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

    async me(userId) {
        const user = await authRepository.findUserById(userId);
 
        if (!user) {
            return {
                success: false,
                error: "A felhasználó nem található."
            };
        }
 
        return {
            success: true,
            data: {
                id: user.id,
                user: user
            }
        };
    }

    async forgetPassword({ email }) {
        const user = await authRepository.login(email);

        if (!user || !user.id) {
            return { success: true };
        }
 
        const resetToken = Token.generate();
 
        const expiresAt = new Date();
        expiresAt.setMinutes(expiresAt.getMinutes() + Number(process.env.PASSWORD_RESET_TOKEN_EXPIRES_MINUTES || 30));
 
        await authRepository.createToken({
            user_id: user.id,
            token: resetToken,
            type: "password",
            expires_at: expiresAt
        });
 
        await authUserEmailService.forgotPassword({
            username: user.username,
            email: user.email,
            token: resetToken
        });

        return { success: true };
    }
 
    async resetPassword({ token, password }) {
        const resetToken = await authRepository.findToken(token);
 
        if (!resetToken) {
            return {
                success: false,
                error: "Érvénytelen vagy már felhasznált token."
            };
        }
 
        const now = new Date();
        const expiresAt = new Date(resetToken.expires_at);
 
        if (expiresAt <= now) {
            await authRepository.deleteToken(token);
 
            return {
                success: false,
                error: "A token lejárt, kérj egy újat."
            };
        }
 
        const passwordHash = await Encryption.hash(password);
 
        await authRepository.updateUserPassword(resetToken.user_id, passwordHash);
 
        await authRepository.deleteToken(token);
 
        return { success: true };
    }

    async confirmEmail({ token }) {
        const confirmToken = await authRepository.findToken(token);
        console.log(confirmToken);
        if (!confirmToken) {
            return {
                success: false,
                error: "Érvénytelen vagy már felhasznált token."
            };
        }
    
        if (confirmToken.token_type !== "register") {
            return {
                success: false,
                error: "Érvénytelen token típus."
            };
        }
    
        const now = new Date();
        const expiresAt = new Date(confirmToken.expires_at);
    
        if (expiresAt <= now) {
            await authRepository.deleteToken(token);
        
            return {
                success: false,
                error: "A token lejárt, kérj egy új megerősítő emailt."
            };
        }
    
        await authRepository.confirmEmail(confirmToken.user_id);
    
        await authRepository.deleteToken(token);
    
        return { success: true };
    }

     async resendConfirmationEmail({ email }) {
        const user = await authRepository.login(email);

        if (!user || !user.id) {
            return { success: true };
        }

        if (user.email_verified == 1) {
            return { success: true };
        }

        const newRegistrationToken = Token.generate();

        const registrationExpiresAt = new Date(Date.now() + 10 * 60 * 1000);

        await authRepository.createToken({
            user_id: user.id,
            token: newRegistrationToken,
            type: "register",
            expires_at: registrationExpiresAt
        });

        await authUserEmailService.register({
            username: user.username,
            email: user.email,
            token: newRegistrationToken
        });

        return { success: true };
    }

    async issueTwoFactorCode(user, maxAttempts = 3) {
        const expiresAt = new Date(Date.now() + twoFactoryCodeConfig.TWO_FACTOR_CODE_EXPIRES_IN);
 
        let lastErr;
        for (let attempt = 0; attempt < maxAttempts; attempt++) {
            const code = generateTwoFactorCode();
            try {
                await authRepository.createToken({
                    user_id: user.id,
                    token: code,
                    type: "2fa",
                    expires_at: expiresAt
                });
                return code;
            } catch (err) {
                lastErr = err;
            }
        }
        throw lastErr;
    }
 
    async verifyTwoFactor({ username, email, code, client }) {
        const loginIdentifier = username || email;
        const user = await authRepository.login(loginIdentifier);
 
        if (!user || !user.id) {
            return {
                success: false,
                error: "Érvénytelen adatok."
            };
        }
 
        const tokenRow = await authRepository.findToken(code);
 
        if (!tokenRow) {
            return {
                success: false,
                error: "Érvénytelen vagy lejárt kód."
            };
        }
 
        if (tokenRow.token_type !== "2fa" || tokenRow.user_id !== user.id) {
            return {
                success: false,
                error: "Érvénytelen kód."
            };
        }
 
        const now = new Date();
        const expiresAt = new Date(tokenRow.expires_at);
 
        if (expiresAt <= now) {
            await authRepository.deleteToken(code);
 
            return {
                success: false,
                error: "A kód lejárt, próbálj meg újra bejelentkezni."
            };
        }
 
        await authRepository.deleteToken(code);
 
        const accessToken = JWT.generateAccessToken({
            id: user.id,
            type: user.type || "user"
        });
 
        const refreshToken = Token.generate();
 
        const refreshExpiresAt = new Date();
        refreshExpiresAt.setDate(refreshExpiresAt.getDate() + Number(jwtConfig.REFRESH_TOKEN_EXPIRES_DAYS || 30));
 
        await authRepository.createRefreshToken({
            user_id: user.id,
            token: refreshToken,
            user_agent: client.user_agent,
            accept_language: client.accept_language,
            sec_ch_ua: client.sec_ch_ua,
            sec_ch_ua_mobile: client.sec_ch_ua_mobile,
            sec_ch_ua_platform: client.sec_ch_ua_platform,
            expires_at: refreshExpiresAt
        });
 
        return {
            success: true,
            data: {
                id: user.id,
                username: user.username,
                email: user.email,
                accessToken: accessToken,
                refreshToken: refreshToken
            }
        };
    }
 
    async setTwoFactorStatus(userId, enabled) {
        await authRepository.setTwoFactorStatus(userId, enabled ? 1 : 0);
        return { success: true };
    }
}
module.exports = UserService;