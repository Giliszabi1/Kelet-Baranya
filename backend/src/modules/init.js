const router = require("express").Router();
const auth = require('./auth/init');

router.use("/auth", auth)

module.exports = router;