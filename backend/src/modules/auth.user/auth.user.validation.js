const Joi = require("joi");

const usernameValidation = require('../../shared/validation/username.validation');
const emailValidation = require('../../shared/validation/email.validation');
const passwordValidation = require('../../shared/validation/password.validation');
const fullnameValidation = require('../../shared/validation/fullname.validation');
const tokenValidation = require('../../shared/validation/token.validation');

class usersSchemas {
    
    registrationSchema = Joi.object({
        username: usernameValidation.required(),
        email: emailValidation.required(),
        fullname: fullnameValidation.optional(),
        password: passwordValidation.required().invalid(Joi.ref("username"))
    })

    loginSchema = Joi.object({
        username: usernameValidation.empty("").optional(),
        email: emailValidation.empty("").optional(),
        password: passwordValidation.required().invalid(Joi.ref("username"))
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

    refreshSchema = Joi.object({
        refreshToken: tokenValidation
    });

    logoutSchema = Joi.object({
        refreshToken: tokenValidation
    });

    forgetPasswordSchema = Joi.object({
        email: emailValidation.required()
    });

    resetPasswordSchema = Joi.object({
        token: tokenValidation.required(),
        password: passwordValidation.required()
    });

    confirmEmailSchema = Joi.object({
        token: tokenValidation.empty("").required()
    })
    resendConfirmationEmailSchema = Joi.object({
        email: emailValidation.empty("").required()
    })

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

module.exports = new usersSchemas();