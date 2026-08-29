const router = require("express").Router();

const auth_twoFaRoutes = require('./twoFactorAuth/auth.twoFactorAuth.routes');
const auth_userRoutes = require('./user/auth.user.routes');
const auth_organizerRoutes = require('./organizer/auth.organizer.routes');

router.use("/2fa", auth_twoFaRoutes)
router.use("/user", auth_userRoutes)
router.use("/organizer", auth_organizerRoutes)

module.exports = router;