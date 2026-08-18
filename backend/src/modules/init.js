const router = require("express").Router();

const usersRoutes = require('./users/users.routes');
const auth_userRoutes = require('./auth.user/auth.user.routes');



//router.use("/user", usersRoutes)
router.use("/auth/user", auth_userRoutes)
//router.use("/auth/organizer", authRoutes)

module.exports = router;