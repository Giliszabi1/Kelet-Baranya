const router = require("express").Router();

const authController = require("./auth.user.controller");

const authenticate = require('../../shared/utils/authenticate');

const authorize = require('../../shared/utils/authorize');

const authSchemas = require('./auth.user.validation');


const validate = require('../../shared/utils/validation');

const manualTest = require('../../../tests/manual/validation.test');

//router.post("/register", validate(authSchemas.registrationSchema), manualTest);
router.post("/register", validate(authSchemas.registrationSchema), authController.register);
router.post("/login", validate(authSchemas.loginSchema),  authController.login);

router.post("/refresh", /*validate(authSchemas.refreshSchema),*/ authController.refresh);
router.post("/logout", /*validate(authSchemas.logoutSchema),*/ authController.logout);

router.get("/me", authenticate, authorize("user"), authController.me);

router.post("/forget-password", validate(authSchemas.forgetPasswordSchema), authController.forgetPassword)
router.post("/reset-password", validate(authSchemas.resetPasswordSchema), authController.resetPassword)

router.get("/confirm-email", validate(authSchemas.confirmEmailSchema), authController.confirmEmail);

router.post("/resend-confirmation-email", validate(authSchemas.resendConfirmationEmailSchema), authController.resendConfirmationEmail);

router.post("/2fa/verify", validate(authSchemas.twoFactorVerifySchema), authController.verifyTwoFactor);

router.post("/2fa/enable", authenticate, authorize("user"), authController.enableTwoFactor);
router.post("/2fa/disable", authenticate, authorize("user"), authController.disableTwoFactor);

module.exports = router;
