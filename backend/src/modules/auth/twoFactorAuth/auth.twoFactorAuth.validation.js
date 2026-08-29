const Joi = require("joi");

const usernameValidation = require('../../../shared/validation/username.validation');
const emailValidation = require('../../../shared/validation/email.validation');


class twoFaSchemas {

    twoFactorVerifySchema = Joi.object({
        username: usernameValidation.empty("").optional(),
        email: emailValidation.empty("").optional(),
        code: Joi.string()
            .length(6)
            .pattern(/^[0-9]+$/)
            .required()
            .messages({
                "string.length": "A kódnak 6 számjegyből kell állnia.",
                "string.pattern.base": "A kód csak számjegyeket tartalmazhat.",
                "string.empty": "A kód megadása kötelező."
            })
    })
    .custom((value, helpers) => {
        if (!value.username && !value.email) {
            return helpers.error("object.missing");
        }
        return value;
    })
    .messages({
        "object.missing": "USERNAME_OR_EMAIL_REQUIRED"
    });
        
}

module.exports = new twoFaSchemas();