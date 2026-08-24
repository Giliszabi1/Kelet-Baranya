const twoFaService = require('./auth.twoFactorAuth.service');


class twofaController {
    constructor() {
        this.twoFaService = new twoFaService();

        this.verifyTwoFactor = this.verifyTwoFactor.bind(this);
        this.enableTwoFactor = this.enableTwoFactor.bind(this);
        this.disableTwoFactor = this.disableTwoFactor.bind(this);
    }


    async verifyTwoFactor(req, res, next) {
        try {
            const { username, email, code } = req.body;
 
            const client = {
                user_agent: req.headers["user-agent"] || null,
                accept_language: req.headers["accept-language"] || null,
                sec_ch_ua: req.headers["sec-ch-ua"] || null,
                sec_ch_ua_mobile: req.headers["sec-ch-ua-mobile"] || null,
                sec_ch_ua_platform: req.headers["sec-ch-ua-platform"] || null
            };
 
            const result = await this.twoFaService.verifyTwoFactor({
                username,
                email,
                code,
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
                message: "Bejelentkezés véglegesítve.",
                data: result.data
            });
 
        } catch (err) {
            next(err);
        }
    }
 
    async enableTwoFactor(req, res, next) {
        try {
            const userId = req.user.id;

            await this.twoFaService.setTwoFactorStatus(userId, true);
 
            return res.status(200).json({
                success: true,
                code: 200,
                message: "2FA_LOGIN_TRUE"
            });
        } catch (err) {
            next(err);
        }
    }
 
    async disableTwoFactor(req, res, next) {
        try {
            const userId = req.user.id;
 
            await this.twoFaService.setTwoFactorStatus(userId, false);
 
            return res.status(200).json({
                success: true,
                code: 200,
                message: "2FA_LOGIN_FALSE"
            });
        } catch (err) {
            next(err);
        }
    }
}

module.exports = new twofaController();