const router = require("express").Router();

const twoFaController = require("./auth.twoFactorAuth.controller");

const authenticate = require('../../shared/utils/authenticate');

const authorize = require('../../shared/utils/authorize');

const twoFaSchemas = require('./auth.twoFactorAuth.validation');


const validate = require('../../shared/utils/validation');

const manualTest = require('../../../tests/manual/validation.test');

router.post("/verify", validate(twoFaSchemas.twoFactorVerifySchema), twoFaController.verifyTwoFactor);

router.post("/enable", authenticate, authorize("user"), twoFaController.enableTwoFactor);
router.post("/disable", authenticate, authorize("user"), twoFaController.disableTwoFactor);

module.exports = router;