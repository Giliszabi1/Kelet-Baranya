const Joi = require("joi");

const emailValidation = Joi.string()
    .email()
    .messages({
        "string.empty": "EMAIL_REQUIRED",
        "string.email": "EMAIL_INVALID"
    })
module.exports = emailValidation;