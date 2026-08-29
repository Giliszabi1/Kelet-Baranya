const jwtConfig = require('../../../config/app.config').jwtRefreshTokenConfig();

const issueTwoFactorCode = require("../twoFactorAuth/auth.twoFactorAuth.service").issueTwoFactorCode;

const authRepository  = require('./auth.organizer.repository');
const logService = require("../../log/log.service")

const Encryption = require("../../../shared/utils/password")
const JWT = require("../../../shared/utils/jwt");
const Token = require('../../../shared/utils/token');

const authUserEmailService = require('./auth.organizer.email.service');

 

class OrganizerService {
    

    async register({username, email, password, fullname, client}) {

        const passwordHash = await Encryption.hash(password);

        const user = await authRepository.register(username, email, passwordHash, fullname);

        const accessToken = JWT.generateAccessToken({ id: user.id, type: user.type || "organizer" });
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

        await logService.create({
            actor_id: user.id,
            actor_role: user.type || "organizer",
            action: "ORGANIZER_REGISTERED",
            status: "success",
            description: null,
            entity_type: "organizer",
            entity_id: user.id,
            old_data: null,
            new_data: JSON.stringify({
                username: user.username,
                email: user.email
            }),
            ip_address: client.ip_address || null
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

        if(user.success == 0){
            if(user.message == "LOGIN_IDENTIFIRY_CANNOT_BE_EMPTY"){

                await logService.create({
                    actor_id: null,
                    actor_role: null,
                    action: "USER_LOGIN",
                    status: "fail",
                    description: "USER_NOT_FOUND_IN_DATABASE",
                    entity_type: "user",
                    entity_id: null,
                    old_data: null,
                    new_data: JSON.stringify({
                        username: user.username,
                        email: user.email
                    }),
                    ip_address: client.ip_address || null
                });

                return {
                    success: false,
                    error: user
                }
            }
        }

        const password_verification = await Encryption.verify(password, user.password_hash);
        if(!password_verification){

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_LOGIN",
                status: "fail",
                description: "ORGANIZER_BAD_PASSWORD",
                entity_type: "organizer",
                entity_id: user.id,
                old_data: null,
                new_data: JSON.stringify({
                    username: user.username
                }),
                ip_address: client.ip_address || null
            });

            return{
                success: false,
                error: "a jelszó nem megfelelő."
            }
        }

        if (user.two_factor_enabled) {
            const code = await issueTwoFactorCode(user);
 
            await authUserEmailService.sendTwoFactorCode({
                username: user.username,
                email: user.email,
                code: code
            });

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_LOGIN",
                status: "success",
                description: "ORGANIZER_2FA_REQUIRED",
                entity_type: "organizer",
                entity_id: user.id,
                old_data: null,
                new_data: JSON.stringify({
                    requires2FA: true,
                }),
                ip_address: client.ip_address || null
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
            type: user.type || "organizer"
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

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "ORGANIZER_LOGIN",
            status: "success",
            description: "ORGANIZER_LOGIN_SUCCESSFUL",
            entity_type: "organizer",
            entity_id: user.id,
            old_data: null,
            new_data: null,
            ip_address: client.ip_address || null
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
        const refreshToken = await authRepository.findRefreshTokenOrganizer(token);

        if (!refreshToken) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_TOKEN_REFRESH",
                status: "fail",
                description: "INVALID_REFRESH_TOKEN",
                entity_type: "organizer",
                entity_id: null,
                old_data: null,
                new_data: JSON.stringify({

                }),
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "Érvénytelen refresh token."
            };
        }

        if (refreshToken.revoked_at) {

            await logService.create({
                actor_id: null,
                actor_role: "organizer",
                action: "ORGANIZER_TOKEN_REFRESH",
                status: "fail",
                description: "REVOKED_REFRESH_TOKEN",
                entity_type: "organizer",
                entity_id: refreshToken.user_id || null,
                old_data: null,
                new_data: JSON.stringify({

                }),
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "A refresh token vissza lett vonva."
            };
        }

        const now = new Date();
        const expiresAt = new Date(refreshToken.expires_at);

        if (expiresAt <= now) {

            await authRepository.revokeRefreshToken(token);

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_TOKEN_REFRESH",
                status: "fail",
                description: "EXPIRED_REFRESH_TOKEN",
                entity_type: "organizer",
                entity_id: refreshToken.user_id || null,
                old_data: null,
                new_data: JSON.stringify({

                }),
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "A refresh token lejárt."
            };
        }

        const accessToken = JWT.generateAccessToken({
            id: refreshToken.user_id,
            type: refreshToken.type || "organizer"
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

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "ORGANIZER_TOKEN_REFRESH",
            status: "success",
            description: "ACCESS_TOKEN_REFRESHED",
            entity_type: "organizer",
            entity_id: refreshToken.user_id,
            old_data: null,
            new_data: null,
            ip_address: client.ip_address || null
        });

        return {
            success: true,
            data: {
                accessToken,
                refreshToken: newRefreshToken
            }
        };
    }

    async logout(token, client) {

        const refreshToken = await authRepository.findRefreshTokenOrganizer(token);
        
        if (!refreshToken) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_LOGOUT",
                status: "fail",
                description: "INVALID_REFRESH_TOKEN",
                entity_type: "organizer",
                entity_id: null,
                old_data: null,
                new_data: JSON.stringify({

                }),
                ip_address: client.ip_address || null
            });

            

            return {
                success: false,
                error: "Érvénytelen refresh token."
            };
        }

        await authRepository.revokeRefreshToken(token);

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "ORGANIZER_LOGOUT",
            status: "success",
            description: "ORGANIZER_LOGOUT_SUCCESSFUL",
            entity_type: "organizer",
            entity_id: refreshToken.user_id || null,
            old_data: null,
            new_data: null,
            ip_address: client.ip_address || null
        });
    
        return {
            success: true
        };
    }

    async me(userId, client) {
        const user = await authRepository.findOrganizerById(userId);
 
        if (!user) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_AUTH_ME",
                status: "fail",
                description: "ORGANIZER_NOT_FOUND_IN_DATABASE",
                entity_type: "organizer",
                entity_id: userId,
                old_data: null,
                new_data: JSON.stringify({
                    userId: userId
                }),
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "A felhasználó nem található."
            };
        }

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "ORGANIZER_AUTH_ME",
            status: "success",
            description: "ORGANIZER_ACCOUNT_INFO_RETRIEVED",
            entity_type: "organizer",
            entity_id: user.id,
            old_data: null,
            new_data: JSON.stringify({
                user: user.username
            }),
            ip_address: client.ip_address || null
        });
 
        return {
            success: true,
            data: {
                id: user.id,
                user: user
            }
        };
    }

    async forgetPassword({ email, client }) {
        const user = await authRepository.login(email);

        if (!user || !user.id) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_FORGET_PASSWORD",
                status: "fail",
                description: "ORGANIZER_NOT_FOUND_IN_DATABASE",
                entity_type: "organizer",
                entity_id: null,
                old_data: null,
                new_data: JSON.stringify({
                    email: email
                }),
                ip_address: client.ip_address || null
            });

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

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "ORGANIZER_FORGET_PASSWORD",
            status: "success",
            description: "ORGANIZER_GET_PASSWORD_RESET_EMAIL",
            entity_type: "organizer",
            entity_id: user.id,
            old_data: null,
            new_data: JSON.stringify({
                email: email
            }),
            ip_address: client.ip_address || null
        });

        return { success: true };
    }
 
    async resetPassword({ token, password, client }) {
        const resetToken = await authRepository.findToken(token);
 
        if (!resetToken) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_RESET_PASSWORD",
                status: "fail",
                description: "PASSWORD_TOKEN_NOT_FOUND",
                entity_type: "organizer",
                entity_id: null,
                old_data: null,
                new_data: JSON.stringify({

                }),
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "Érvénytelen vagy már felhasznált token."
            };
        }
 
        const now = new Date();
        const expiresAt = new Date(resetToken.expires_at);
 
        if (expiresAt <= now) {
            await authRepository.deleteToken(token);
            
            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_RESET_PASSWORD",
                status: "fail",
                description: "EXPIRED_RESET_PASSWORD_TOKEN",
                entity_type: "organizer",
                entity_id: resetToken.user_id,
                old_data: null,
                new_data: JSON.stringify({

                }),
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "A token lejárt, kérj egy újat."
            };
        }
 
        const passwordHash = await Encryption.hash(password);
 
        await authRepository.updateUserPassword(resetToken.user_id, passwordHash);
 
        await authRepository.deleteToken(token);

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "ORGANIZER_RESET_PASSWORD",
            status: "success",
            description: "ORGANIZER_PASSWORD_RESET_SUCCESSFUL",
            entity_type: "organizer",
            entity_id: resetToken.user_id,
            old_data: null,
            new_data: JSON.stringify({

            }),
            ip_address: client.ip_address || null
        });
 
        return { success: true };
    }

    async confirmEmail({ token, client }) {
        const confirmToken = await authRepository.findToken(token);
        console.log(confirmToken);
        if (!confirmToken) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_CONFIRM_EMAIL",
                status: "fail",
                description: "INVALID_CONFIRM_TOKEN",
                entity_type: "organizer",
                entity_id: null,
                old_data: null,
                new_data: JSON.stringify({

                }),
                ip_address: client.ip_address || null
            });

            return {
                success: false,
                error: "Érvénytelen vagy már felhasznált token."
            };
        }
    
        if (confirmToken.token_type !== "register") {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_CONFIRM_EMAIL",
                status: "fail",
                description: "INVALID_CONFIRM_TOKEN_TYPE",
                entity_type: "organizer",
                entity_id: null,
                old_data: null,
                new_data: JSON.stringify({

                }),
                ip_address: client.ip_address || null
            });

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

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "ORGANIZER_CONFIRM_EMAIL",
            status: "success",
            description: null,
            entity_type: "organizer",
            entity_id: confirmToken.user_id,
            old_data: null,
            new_data: JSON.stringify({

            }),
            ip_address: client.ip_address || null
        });

    
        return { success: true };
    }

     async resendConfirmationEmail({ email, client }) {
        const user = await authRepository.login(email);

        if (!user || !user.id) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_RESEND_CONFIRM_EMAIL",
                status: "fail",
                description: "ORGANIZER_NOT_FOUND_BY_EMAIL",
                entity_type: "organizer",
                entity_id: null,
                old_data: null,
                new_data: JSON.stringify({
                    email: email
                }),
                ip_address: client.ip_address || null
            });

            return { success: true };
        }

        if (user.email_verified == 1) {

            await logService.create({
                actor_id: null,
                actor_role: null,
                action: "ORGANIZER_RESEND_CONFIRM_EMAIL",
                status: "fail",
                description: "ORGANIZER_HAS_VERIFY_EMAIL",
                entity_type: "organizer",
                entity_id: user.id,
                old_data: null,
                new_data: JSON.stringify({
                    email: email
                }),
                ip_address: client.ip_address || null
            });

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

        await authUserEmailService.resendConfirmationEmail({
            username: user.username,
            email: user.email,
            token: newRegistrationToken
        });

        await logService.create({
            actor_id: null,
            actor_role: null,
            action: "ORGANIZER_RESEND_CONFIRM_EMAIL",
            status: "success",
            description: "ORGANIZER_VERIFY_EMAIL_SEND",
            entity_type: "organizer",
            entity_id: user.id,
            old_data: null,
            new_data: JSON.stringify({
                email: email
            }),
            ip_address: client.ip_address || null
        });

        return { success: true };
    }
}
module.exports = OrganizerService;