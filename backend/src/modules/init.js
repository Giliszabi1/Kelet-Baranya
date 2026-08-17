const router = require("express").Router();

const usersRoutes = require('./users/users.routes');
const authRoutes = require('./auth.user/auth.user.routes');


//router.use("/user", usersRoutes)
router.use("/auth/user", authRoutes)

module.exports = router;