const twoFaRepository  = require('./auth.twoFactorAuth.repository');

const jwtConfig = require('../../../config/app.config').jwtRefreshTokenConfig();
const twoFactoryCodeConfig = require('../../../config/app.config').twoFactoryCodeConfig();

const generateTwoFactorCode = require("../../../shared/utils/twoFactorCode")

const logService = require("../../log/log.service")

const JWT = require("../../../shared/utils/jwt");
const Token = require('../../../shared/utils/token');

class twofaService {

    static async issueTwoFactorCode(user, maxAttempts = 3) {
        const expiresAt = new Date(Date.now() + twoFactoryCodeConfig.TWO_FACTOR_CODE_EXPIRES_IN);
        let lastErr;
        for (let attempt = 0; attempt < maxAttempts; attempt++) {
            const code = generateTwoFactorCode();
            try {
                await twoFaRepository.createToken({
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

    async verifyTwoFactor({ username, email, code, client}) {
        const loginIdentifier = username || email;
        const user = await twoFaRepository.login(loginIdentifier);
 
        if(user.success == 0){
            if(user.message == "LOGIN_IDENTIFIRY_CANNOT_BE_EMPTY"){
                await logService.create({
                    actor_id: null,
                    actor_role: null,
                    action: "TWO_FACTOR_VERIFY",
                    status: "fail",
                    description: "TWO_FACTOR_USER_NOT_FOUND",
                    entity_type: null,
                    entity_id: null,
                    old_data: null,
                    new_data: JSON.stringify({
                        loginIdentifier: loginIdentifier
                    }),
                    ip_address: client.ip_address || null
                });
            
                return {
                    success: false,
                    error: "Érvénytelen adatok."
                };
            }
        }
 
        const tokenRow = await twoFaRepository.findToken(code);
 
        if (!tokenRow) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "TWO_FACTOR_VERIFY",
                status: "fail",
                description: "TWO_FACTOR_CODE_NOT_FOUND",
                entity_type: user.type || "user",
                entity_id: user.id,
                old_data: null,
                new_data: null,
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "Érvénytelen vagy lejárt kód."
            };
        }
 
        if (tokenRow.token_type !== "2fa" || tokenRow.user_id !== user.id) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "TWO_FACTOR_VERIFY",
                status: "fail",
                description: "TWO_FACTOR_CODE_INVALID",
                entity_type: user.type || "user",
                entity_id: user.id,
                old_data: null,
                new_data: null,
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "Érvénytelen kód."
            };
        }
 
        const now = new Date();
        const expiresAt = new Date(tokenRow.expires_at);
 
        if (expiresAt <= now) {
            await twoFaRepository.deleteToken(code);

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "TWO_FACTOR_VERIFY",
                status: "fail",
                description: "TWO_FACTOR_CODE_EXPIRED",
                entity_type: user.type || "user",
                entity_id: user.id,
                old_data: null,
                new_data: null,
                ip_address: client.ip_address || null
            });
            return {
                success: false,
                error: "A kód lejárt, próbálj meg újra bejelentkezni."
            };
        }
 
        await twoFaRepository.deleteToken(code);
 
        const accessToken = JWT.generateAccessToken({
            id: user.id,
            type: user.type
        });
 
        const refreshToken = Token.generate();
 
        const refreshExpiresAt = new Date();
        refreshExpiresAt.setDate(refreshExpiresAt.getDate() + jwtConfig.REFRESH_TOKEN_EXPIRES_DAYS || 30);
 
        await twoFaRepository.createRefreshToken({
            user_id: user.id,
            token: refreshToken,
            user_agent: client.user_agent,
            accept_language: client.accept_language,
            sec_ch_ua: client.sec_ch_ua,
            sec_ch_ua_mobile: client.sec_ch_ua_mobile,
            sec_ch_ua_platform: client.sec_ch_ua_platform,
            expires_at: refreshExpiresAt
        });

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "TWO_FACTOR_VERIFY",
            status: "success",
            description: "TWO_FACTOR_VERIFIED",
            entity_type: user.type || "user",
            entity_id: user.id,
            old_data: null,
            new_data: null,
            ip_address: client.ip_address || null
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

    async setTwoFactorStatus(userId, client,enabled) {
        await twoFaRepository.setTwoFactorStatus(userId, enabled ? 1 : 0);

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: enabled ? "TWO_FACTOR_ENABLE" : "TWO_FACTOR_DISABLE",
            status: "success",
            description: enabled ? "TWO_FACTOR_ENABLED" : "TWO_FACTOR_DISABLED",
            entity_type: role || "user",
            entity_id: userId,
            old_data: null,
            new_data: null,
            ip_address: (client && client.ip_address) || null
        });

        return { success: true };
    }
}

module.exports = twofaService;