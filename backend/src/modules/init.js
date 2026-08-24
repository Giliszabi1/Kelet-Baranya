const router = require("express").Router();

const usersRoutes = require('./users/users.routes');
const auth_twoFaRoutes = require('./auth.twoFactorAuth/auth.twoFactorAuth.routes');
const auth_userRoutes = require('./auth.user/auth.user.routes');
const auth_organizerRoutes = require('./auth.organizer/auth.organizer.routes');



//router.use("/user", usersRoutes)
router.use("/auth/2fa", auth_twoFaRoutes)
router.use("/auth/user", auth_userRoutes)
router.use("/auth/organizer", auth_organizerRoutes)

module.exports = router;