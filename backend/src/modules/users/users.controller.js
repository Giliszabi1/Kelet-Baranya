const UserService = require('./users.service');

class UserController {
    constructor() {
        this.userService = new UserService();

        this.register = this.register.bind(this);
    }

    async register(req, res, next) {
        try {
            const { username, email, fullname, password } = req.body;
            const user = await this.userService.register({
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

}

module.exports = new UserController();