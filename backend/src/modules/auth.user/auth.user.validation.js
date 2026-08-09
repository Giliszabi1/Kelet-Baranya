const Joi = require("joi");
class usersSchemas {
    
    registrationSchema = Joi.object({
        username: Joi.string()
            .min(5)
            .max(32)
            .required()
            .messages({
                "string.empty": "Username is required",
                "string.min": "Username must be at least 5 characters long",
                "string.max": "Username cannot exceed 32 characters"
            }),

        email: Joi.string()
            .email()
            .required()
            .messages({
                "string.email": "Please enter a valid email address",
                "string.empty": "Email is required"
            }),

        fullname: Joi.string()
            .pattern(/^[A-Za-zÀ-ÖØ-öø-ÿ]+(?:\s+[A-Za-zÀ-ÖØ-öø-ÿ]+)+$/)
            .min(5)
            .max(64)
            .optional()
            .messages({
                "string.pattern.base": "Full name must contain at least a first name and a last name, and can only contain letters",
                "string.min": "Full name must be at least 5 characters long",
                "string.max": "Full name cannot exceed 64 characters"
            }),

        password: Joi.string()
            .min(8)
            .pattern(/[A-Z]/)
            .pattern(/[a-z]/)
            .pattern(/[0-9]/)
            .pattern(/^[A-Za-z0-9!@#$%^&*]+$/)
            .required()
            .messages({
                "string.min": "Password must be at least 8 characters long",
                "string.pattern.base": "Password must contain uppercase letter, lowercase letter, number, and only allowed special characters (!@#$%^&*)"
            })
    });


    loginSchema = Joi.object({
        username: Joi.string()
            .min(5)
            .max(32)
            .messages({
                "string.empty": "Username is required",
                "string.min": "Username must be at least 5 characters long",
                "string.max": "Username cannot exceed 32 characters"
            }),

        email: Joi.string()
            .email()
            .messages({
                "string.email": "Please enter a valid email address",
                "string.empty": "Email is required"
            }),


        password: Joi.string()
            .min(8)
            .pattern(/[A-Z]/)
            .pattern(/[a-z]/)
            .pattern(/[0-9]/)
            .pattern(/^[A-Za-z0-9!@#$%^&*]+$/)
            .required()
            .messages({
                "string.min": "Password must be at least 8 characters long",
                "string.pattern.base": "Password must contain uppercase letter, lowercase letter, number, and only allowed special characters (!@#$%^&*)"
            })
    }).or("username", "email");

}




module.exports = new usersSchemas();