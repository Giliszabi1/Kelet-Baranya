const router = require("express").Router();

const usersRoutes = require('./users/users.routes');
const authRoutes = require('./auth/auth.routes');


router.use("/user", usersRoutes)
router.use("/auth", authRoutes)

module.exports = router;