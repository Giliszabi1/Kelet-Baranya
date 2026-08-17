const Joi = require("joi");

const usernameValidation = Joi.string()
    .min(5)
    .max(32)
    .pattern(/^[\p{L}\p{N}]+$/u)
    .pattern(/[a-zA-Z]/)
    .messages({
        "string.empty": "USERNAME_REQUIRED",
        "string.min": "USERNAME_TOO_SHORT",
        "string.max": "USERNAME_TOO_LONG",
        "string.pattern.base": "USERNAME_INVALID"
    })
module.exports = usernameValidation