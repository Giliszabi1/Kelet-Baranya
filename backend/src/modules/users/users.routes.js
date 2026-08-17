const router = require("express").Router();

const usersController = require("./users.controller");

const usersSchemas = require('./users.validation');


const validate = require('../../shared/utils/validation');


router.post("/register", validate(usersSchemas.registrationSchema), usersController.register);
router.post("/loginByPassword", validate(usersSchemas.registrationSchema), usersController.register);

module.exports = router;
