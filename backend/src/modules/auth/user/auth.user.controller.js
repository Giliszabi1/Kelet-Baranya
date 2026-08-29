const authService = require('./auth.user.service');

class UserController {
    constructor() {
        this.authService = new authService();

        this.register = this.register.bind(this);
        this.login = this.login.bind(this);
        
        this.refresh = this.refresh.bind(this);
        this.logout = this.logout.bind(this);

        this.me = this.me.bind(this);
        
        this.forgetPassword = this.forgetPassword.bind(this);
        this.resetPassword = this.resetPassword.bind(this);

        this.confirmEmail = this.confirmEmail.bind(this);
        this.resendConfirmationEmail = this.resendConfirmationEmail.bind(this);
    }

    async register(req, res, next) {
        try {
            const { username, email, fullname, password } = req.body;

            const client = { 
                user_agent: req.headers["user-agent"] || null, 
                accept_language: req.headers["accept-language"] || null, 
                sec_ch_ua: req.headers["sec-ch-ua"] || null, 
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null, 
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };

            const user = await this.authService.register({
                username,
                email,
                password,
                client
            });

            return res.status(201).json({
                success: true,
                code: 201,
                message: "User registered successfully.",
                data: user
            });
        } catch (err) {
            next(err);
        }
    }

    async login(req, res, next) {
        try {
            const { username, email, password } = req.body;

            const client = { 
                user_agent: req.headers["user-agent"] || null, 
                accept_language: req.headers["accept-language"] || null, 
                sec_ch_ua: req.headers["sec-ch-ua"] || null, 
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null, 
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };
            
            const user = await this.authService.login({
                username, 
                email, 
                password,
                client
            });
           
            if(user.success){

                if (user.requires2FA) {
                    return res.status(200).json({
                        success: true,
                        code: 200,
                        message: "2FA_LOGIN_REQUIRED",
                        requires2FA: true,
                        data: user.data
                    });
                }

                return res.status(200).json({
                    success: true,
                    code: 200,
                    message: "LOGIN_SUCCESSFUL",
                    data: user.data,
                });
            }else{
                next(user.error);
            }
        } catch (err) {
            next(err);
        }
    }

    async refresh(req, res, next) {
        try {

            const { refreshToken } = req.body;

            if (!refreshToken) {
                return res.status(400).json({
                    success: false,
                    code: 400,
                    errors: ["REFRESH_TOKEN_REQUIRED."]
                });
            }

            const client = {
                user_agent: req.headers["user-agent"] || null,
                accept_language: req.headers["accept-language"] || null,
                sec_ch_ua: req.headers["sec-ch-ua"] || null,
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null,
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };

            const result = await this.authService.refresh({
                token: refreshToken,
                client
            });

            if (!result.success) {
                return res.status(401).json({
                    success: false,
                    code: 401,
                    errors: [result.error]
                });
            }

            return res.status(200).json({
                success: true,
                code: 200,
                message: "Token refreshed successfully.",
                data: result.data
            });

        } catch (err) {
            next(err);
        }
    }

    async logout(req, res, next) {
        try {
            const { refreshToken } = req.body;

            const client = {
                user_agent: req.headers["user-agent"] || null,
                accept_language: req.headers["accept-language"] || null,
                sec_ch_ua: req.headers["sec-ch-ua"] || null,
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null,
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };

            if (!refreshToken) {
                return res.status(400).json({
                    success: false,
                    code: 400,
                    errors: ["Refresh token is required."]
                });
            }

            const result = await this.authService.logout(refreshToken, client);

            if (!result.success) {
                return res.status(401).json({
                    success: false,
                    code: 401,
                    errors: [result.error]
                });
            }

            return res.status(200).json({
                success: true,
                code: 200,
                message: "Logout successful."
            });

        } catch (err) {
            next(err);
        }
    }

    async me(req, res, next) {
        try {
            const userId = req.user.id;

            const client = {
                user_agent: req.headers["user-agent"] || null,
                accept_language: req.headers["accept-language"] || null,
                sec_ch_ua: req.headers["sec-ch-ua"] || null,
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null,
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };
 
            const result = await this.authService.me(userId, client);
 
            if (!result.success) {
                return res.status(404).json({
                    success: false,
                    code: 404,
                    errors: [result.error]
                });
            }
 
            return res.status(200).json({
                success: true,
                code: 200,
                message: "Account information retrieved successfully.",
                data: result.data
            });
 
        } catch (err) {
            next(err);
        }
    }

    async forgetPassword(req, res, next) {
        try {
            const { email } = req.body;

            const client = {
                user_agent: req.headers["user-agent"] || null,
                accept_language: req.headers["accept-language"] || null,
                sec_ch_ua: req.headers["sec-ch-ua"] || null,
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null,
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };
 
            await this.authService.forgetPassword({ email, client });
 
            return res.status(200).json({
                success: true,
                code: 200,
                message: "If the provided email address exists in our system, we've sent a password reset email."
            });
        } catch (err) {
            next(err);
        }
    }

    async resetPassword(req, res, next) {
        try {
            const { token, password } = req.body;

            const client = {
                user_agent: req.headers["user-agent"] || null,
                accept_language: req.headers["accept-language"] || null,
                sec_ch_ua: req.headers["sec-ch-ua"] || null,
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null,
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };

            const result = await this.authService.resetPassword({ token, password, client });
 
            if (!result.success) {
                return res.status(400).json({
                    success: false,
                    code: 400,
                    message: result.error
                });
            }
 
            return res.status(200).json({
                success: true,
                code: 200,
                message: "Password has been reset successfully."
            });
 
        } catch (err) {
            next(err);
        }
    }

    async confirmEmail(req, res, next) {
        try {
            const token = req.query.token;
            
            const client = {
                user_agent: req.headers["user-agent"] || null,
                accept_language: req.headers["accept-language"] || null,
                sec_ch_ua: req.headers["sec-ch-ua"] || null,
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null,
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };

            const result = await this.authService.confirmEmail({ token, client });

            if (!result.success) {
                return res.status(400).json({
                    success: false,
                    code: 400,
                    message: result.error
                });
            }

            return res.status(200).json({
                success: true,
                code: 200,
                message: "Email cím sikeresen megerősítve."
            });

        } catch (err) {
            next(err);
        }
    }

    async resendConfirmationEmail(req, res, next) {
        try {
            const { email } = req.body;

            const client = {
                user_agent: req.headers["user-agent"] || null,
                accept_language: req.headers["accept-language"] || null,
                sec_ch_ua: req.headers["sec-ch-ua"] || null,
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null,
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null,
                ip_address: req.ip
            };

            await this.authService.resendConfirmationEmail({ email, client });

            return res.status(200).json({
                success: true,
                code: 200,
                message: "If the provided email address exists in our system, we've sent a password reset email."
            });
        } catch (err) {
            next(err);
        }
    }
}

module.exports = new UserController();