const router = require("express").Router();

const authController = require("./auth.user.controller");

const authenticate = require('../../shared/utils/authenticate');

const authSchemas = require('./auth.user.validation');


const validate = require('../../shared/utils/validation');

const manualTest = require('../../../tests/manual/validation.test');

//router.post("/register", validate(authSchemas.registrationSchema), manualTest);
router.post("/register", validate(authSchemas.registrationSchema), authController.register);
router.post("/login", validate(authSchemas.loginSchema),  authController.login);

router.post("/refresh", /*validate(authSchemas.refreshSchema),*/ authController.refresh);
router.post("/logout", /*validate(authSchemas.logoutSchema),*/ authController.logout);

router.get("/me", authenticate, authController.me);

router.post("/forget-password", validate(authSchemas.forgetPasswordSchema), authController.forgetPassword)
router.post("/reset-password", validate(authSchemas.resetPasswordSchema), authController.resetPassword)

router.get("/confirm-email", validate(authSchemas.confirmEmailSchema), authController.confirmEmail);

router.post("/resend-confirmation-email", validate(authSchemas.resendConfirmationEmailSchema), authController.resendConfirmationEmail);


module.exports = router;
