const Joi = require("joi");

const passwordValidation = Joi.string()
    .min(8)
    .max(64)
    .pattern(/[A-Z]/)
    .pattern(/[a-z]/)
    .pattern(/[0-9]/)
    .pattern(/^[A-Za-z0-9!@#$%^&*]+$/)
    .messages({
        "string.empty": "PASSWORD_REQUIRED",
        "string.min": "PASSWORD_TOO_SHORT",
        "string.pattern.base": "PASSWORD_INVALID",
        "any.invalid": "USERNAME_PASSWORD_IDENTICAL"
    })
module.exports = passwordValidation;