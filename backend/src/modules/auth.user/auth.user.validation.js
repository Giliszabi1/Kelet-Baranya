const Joi = require("joi");
class usersSchemas {
    
    registrationSchema = Joi.object({
        username: Joi.string()
            .min(5)
            .max(32)
            .required()
            .messages({
                "string.empty": "USERNAME_REQUIRED",
                "string.min": "USERNAME_TOO_SHORT",
                "string.max": "USERNAME_TOO_LONG"
            }),

        email: Joi.string()
            .email()
            .required()
            .messages({
                "string.empty": "EMAIL_REQUIRED",
                "string.email": "EMAIL_INVALID"
            }),

        fullname: Joi.string()
            .pattern(/^[A-Za-zÀ-ÖØ-öø-ÿ]+(?:\s+[A-Za-zÀ-ÖØ-öø-ÿ]+)+$/)
            .min(5)
            .max(64)
            .optional()
            .messages({
                "string.pattern.base": "FULLNAME_INVALID",
                "string.min": "FULLNAME_TOO_SHORT",
                "string.max": "FULLNAME_TOO_LONG"
            }),

        password: Joi.string()
            .min(8)
            .pattern(/[A-Z]/)
            .pattern(/[a-z]/)
            .pattern(/[0-9]/)
            .pattern(/^[A-Za-z0-9!@#$%^&*]+$/)
            .invalid(Joi.ref("username"))
            .required()
            .messages({
                "string.empty": "PASSWORD_REQUIRED",
                "string.min": "PASSWORD_TOO_SHORT",
                "string.pattern.base": "PASSWORD_INVALID",
                "any.invalid": "USERNAME_PASSWORD_IDENTICAL"
            })
    });


    loginSchema = Joi.object({
        username: Joi.string()
            .min(5)
            .max(32)
            .messages({
                "string.empty": "USERNAME_REQUIRED",
                "string.min": "USERNAME_TOO_SHORT",
                "string.max": "USERNAME_TOO_LONG"
            }),

        email: Joi.string()
            .email()
            .messages({
                "string.empty": "EMAIL_REQUIRED",
                "string.email": "EMAIL_INVALID"
            }),


        password: Joi.string()
            .min(8)
            .pattern(/[A-Z]/)
            .pattern(/[a-z]/)
            .pattern(/[0-9]/)
            .pattern(/^[A-Za-z0-9!@#$%^&*]+$/)
            .required()
            .messages({
                "string.empty": "PASSWORD_REQUIRED",
                "string.min": "PASSWORD_TOO_SHORT",
                "string.pattern.base": "PASSWORD_INVALID"
            })
        })
    .or("username", "email")
    .messages({
        "object.missing": "USERNAME_OR_EMAIL_REQUIRED"
    });

    forgetPasswordSchema = Joi.object({
        email: Joi.string()
            .email()
            .required()
            .messages({
                "string.empty": "EMAIL_REQUIRED",
                "string.email": "EMAIL_INVALID"
            })
    });

    resetPasswordSchema = Joi.object({
        token: Joi.string()
            .required()
            .messages({
                "string.empty": "RESET_TOKEN_REQUIRED"
            }),
 
        password: Joi.string()
            .min(8)
            .pattern(/[A-Z]/)
            .pattern(/[a-z]/)
            .pattern(/[0-9]/)
            .pattern(/^[A-Za-z0-9!@#$%^&*]+$/)
            .required()
            .messages({
                "string.empty": "PASSWORD_REQUIRED",
                "string.min": "PASSWORD_TOO_SHORT",
                "string.pattern.base": "PASSWORD_INVALID"
            })
    });
}




module.exports = new usersSchemas();