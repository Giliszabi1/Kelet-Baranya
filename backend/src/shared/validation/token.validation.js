const Joi = require("joi");

const tokenValidation = Joi.string()
    .length(128)
    .messages({
        "any.required": "TOKEN_REQUIRED",
        "string.empty": "TOKEN_REQUIRED",
        "string.length": "TOKEN_TOO_SHORT_OR_LONG",
    });

module.exports = tokenValidation;