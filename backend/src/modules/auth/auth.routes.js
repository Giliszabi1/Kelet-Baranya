const router = require("express").Router();

const authController = require("./auth.controller");

const authSchemas = require('./auth.validation');


const validate = require('../../utils/validation');


router.post("/register", validate(authSchemas.registrationSchema), authController.register);
router.post("/login", validate(authSchemas.loginSchema),  authController.login);

module.exports = router;
