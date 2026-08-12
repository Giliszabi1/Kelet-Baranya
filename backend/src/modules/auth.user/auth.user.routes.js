const router = require("express").Router();

const authController = require("./auth.user.controller");

const authSchemas = require('./auth.user.validation');


const validate = require('../../utils/validation');

const manualTest = require('../../../tests/manual/validation.test');

//router.post("/register", validate(authSchemas.registrationSchema), authController.register);
router.post("/register", validate(authSchemas.registrationSchema), manualTest);
router.post("/login", validate(authSchemas.loginSchema),  authController.login);

router.post("/refresh", authController.refresh);
router.post("/logout", authController.logout);

router.post("/forget-password", validate(authSchemas.forgetPasswordSchema), authController.forgetPassword)
router.post("/reset-password", validate(authSchemas.resetPasswordSchema), authController.resetPassword)

module.exports = router;
