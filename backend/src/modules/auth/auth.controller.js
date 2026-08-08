const authService = require('./auth.service');

class UserController {
    constructor() {
        this.authService = new authService();

        this.register = this.register.bind(this);
    }

    async register(req, res, next) {
        try {
            const { username, email, fullname, password } = req.body;
            const user = await this.authService.register({
                username,
                email,
                password,
            });

            return res.status(201).json({
                success: true,
                message: "User registered successfully.",
                data: user,
            });
        } catch (err) {
            next(err);
        }
    }

    async login(req, res, next) {
        try {

            const { username, email, password } = req.body;

            const user = await this.authService.login({
                username, 
                email, 
                password
            });

            return res.status(201).json({
                success: true,
                message: "User login successfully.",
                data: user,
            });
        } catch (err) {
            next(err);
        }
    }

}

module.exports = new UserController();