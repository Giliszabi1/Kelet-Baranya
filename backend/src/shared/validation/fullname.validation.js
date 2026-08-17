const Joi = require("joi");

const fullnameValidation = Joi.string()
    .pattern(/^[\p{L}]+(?: +[\p{L}]+)+$/u)
    .min(5)
    .max(64)
    .messages({
        "string.empty": "FULLNAME_REQUIRED",
        "string.pattern.base": "FULLNAME_INVALID",
        "string.min": "FULLNAME_TOO_SHORT",
        "string.max": "FULLNAME_TOO_LONG"
    });

module.exports = fullnameValidation;